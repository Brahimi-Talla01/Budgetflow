import 'package:budgetflow/models/income_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class IncomeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Income> _incomes = [];
  List<Income> get incomes => _incomes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  //Ajouter un revenus
  Future<void> addIncome({
    required double amount,
    required String source,
    required String description,
    required DateTime date,
    String? projectId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté!");

      final income = Income(
        id: '',
        userId: user.uid,
        amount: amount,
        source: source,
        date: date,
        description: description,
        projectId: projectId,
      );

      //Ajout dans Firebase
      final docRef = await _firestore.collection("incomes").add(income.toMap());

      //Mise à jour de l'id du revenue
      await docRef.update({'id': docRef.id});

      //Ajout du revenu en local
      _incomes.add(income.copyWith(id: docRef.id));

      _isLoading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur lors de l'ajout : $e");
    }
  }

  /// Récupérer tout les revenus de l’utilisateur connecté
  Future<void> fetchUserIncomes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      final snapshot = await _firestore
          .collection('incomes')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      _incomes = snapshot.docs
          .map((doc) => Income.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur lors du chargement : $e");
    }
  }

  /// Supprimer un un revenu
  Future<void> deleteIncome(String id) async {
    try {
      await _firestore.collection('incomes').doc(id).delete();
      _incomes.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de la suppression : $e");
    }
  }

  /// Nettoyer les données (par exemple lors du logout)
  void clearIncomes() {
    _incomes = [];
    notifyListeners();
  }
}
