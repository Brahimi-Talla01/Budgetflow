import 'package:budgetflow/models/project_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProjectProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Ajouter un nouveau projet
  Future<void> addProject({
    required String name,
    required double targetAmount,
    required Color color,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      final project = Project(
        id: '', // Firestore va générer l'ID temporairement
        userId: user.uid,
        name: name,
        targetAmount: targetAmount,
        creationDate: DateTime.now(),
        color: color,
      );

      // Ajouter dans Firestore dans la collection 'projects'
      final docRef = await _firestore
          .collection('projects')
          .add(project.toMap());

      // Mettre à jour l'ID du projet (celui généré par Firestore)
      await docRef.update({'id': docRef.id});

      // Ajouter localement et trier par date de création
      _projects.add(project.copyWith(id: docRef.id));
      _projects.sort((a, b) => b.creationDate.compareTo(a.creationDate));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur lors de l’ajout du projet : $e");
    }
  }

  /// Récupérer tous les projets de l’utilisateur connecté
  Future<void> fetchUserProjects() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      final snapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: user.uid)
          .orderBy('creationDate', descending: true)
          .get();

      _projects = snapshot.docs
          .map((doc) => Project.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur lors du chargement des projets : $e");
    }
  }

  /// Supprimer un projet
  Future<void> deleteProject(String id) async {
    try {
      await _firestore.collection('projects').doc(id).delete();
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de la suppression du projet : $e");
    }
  }

  /// Fonction utilitaire pour trouver un projet par son ID
  Project? getProjectById(String? id) {
    if (id == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour un projet
  Future<void> updateProject({
    required String projectId,
    String? newName,
    double? newTargetAmount,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Référence du projet à modifier
      final projectRef = _firestore.collection('projects').doc(projectId);

      //Préparer les champs à mettre à jour
      final Map<String, dynamic> updatedData = {};

      if (newName != null && newName.isNotEmpty) {
        updatedData['name'] = newName;
      }
      if (newTargetAmount != null) {
        updatedData['targetAmount'] = newTargetAmount;
      }

      if (updatedData.isEmpty) {
        debugPrint('Aucun champ à mettre à jour');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Mise à jour dans Firestore
      await projectRef.update(updatedData);

      // Mise à jour locale (pour éviter de recharger tout)
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        final oldProject = _projects[index];
        _projects[index] = oldProject.copyWith(
          name: newName ?? oldProject.name,
          targetAmount: newTargetAmount ?? oldProject.targetAmount,
        );
      }

      notifyListeners();
      debugPrint('Projet mis à jour avec succès.');
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du projet : $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Nettoyer les données (Lors du logout)
  void clearProjects() {
    _projects = [];
    notifyListeners();
  }
}
