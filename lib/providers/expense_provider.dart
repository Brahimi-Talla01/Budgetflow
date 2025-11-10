import 'package:budgetflow/models/expense_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Ajouter une dépense
  Future<void> addExpense({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    String? projectId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      final expense = Expense(
        id: '', // Firestore va le générer
        userId: user.uid,
        amount: amount,
        category: category,
        date: date,
        description: description,
        projectId: projectId,
      );

      // Ajouter dans Firestore
      final docRef = await _firestore
          .collection('expenses')
          .add(expense.toMap());

      // Mettre à jour l'ID de la dépense (celui généré par Firestore)
      await docRef.update({'id': docRef.id});

      // Ajouter localement
      _expenses.add(expense.copyWith(id: docRef.id));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur lors de l’ajout : $e");
    }
  }

  /// Récupérer toutes les dépenses de l’utilisateur connecté
  Future<void> fetchUserExpenses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      _expenses = snapshot.docs
          .map((doc) => Expense.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur lors du chargement : $e");
    }
  }

  /// Supprimer une dépense
  Future<void> deleteExpense(String id) async {
    try {
      await _firestore.collection('expenses').doc(id).delete();
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de la suppression : $e");
    }
  }

  /// Nettoyer les données (par exemple lors du logout)
  void clearExpenses() {
    _expenses = [];
    notifyListeners();
  }
}
