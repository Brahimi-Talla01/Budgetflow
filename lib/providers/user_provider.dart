import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgetflow/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUserData;
  bool _isLoading = false;

  // --- GETTERS ---
  UserModel? get currentUserData => _currentUserData;
  bool get isLoading => _isLoading;

  // --- PRIVATE HELPERS ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- CHARGER LES DONNÉES UTILISATEUR ---
  Future<void> fetchUserData(String uid) async {
    _setLoading(true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        _currentUserData = UserModel.fromMap(doc.data()!);
      } else {
        _currentUserData = null;
        debugPrint("Profil utilisateur non trouvé pour UID: $uid");
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des données utilisateur: $e");
    } finally {
      _setLoading(false);
    }
  }

  // --- MODIFIER LE NOM D'UTILISATEUR ---
  Future<void> updateUserName(String newName) async {
    if (_currentUserData == null) return;

    _setLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserData!.uid)
          .update({'name': newName});

      // Met à jour localement
      _currentUserData = _currentUserData!.copyWith(name: newName);
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour du nom : $e");
    } finally {
      _setLoading(false);
    }
  }

  // --- RÉINITIALISER LES DONNÉES À LA DÉCONNEXION ---
  void clearUserData() {
    _currentUserData = null;
    notifyListeners();
  }
}
