import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:budgetflow/providers/expense_provider.dart';
import 'package:budgetflow/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgetflow/models/user_model.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Propriété pour l'utilisateur Firebase (pour la déconnexion/connexion)
  User? get currentUser => _auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Créer un compte utilisateur
  Future<void> signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = cred.user!.uid;

      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        photoURL: cred.user?.photoURL,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      // Déclencher le chargement des données dans le UserProvider
      if (context.mounted) {
        // Le newUser est déjà créé, on peut le charger via fetchUserData
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).fetchUserData(uid);
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.message ?? "Erreur lors de l'inscription");
    }
  }

  /// Connexion
  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Déclencher le chargement des données dans le UserProvider
      if (context.mounted) {
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).fetchUserData(cred.user!.uid);
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.message ?? "Erreur de connexion");
    }
  }

  //-------- CONNEXION AVEC UN COMPTE GOOGLE-------

  Future<void> ensureInitialized() {
    return GoogleSignInPlatform.instance.init(const InitParameters());
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    // Ajout du context
    try {
      _isLoading = true;
      notifyListeners();

      await ensureInitialized();

      // Logique d'authentification Google
      final AuthenticationResults result = await GoogleSignInPlatform.instance
          .authenticate(const AuthenticateParameters());

      final String? idToken = result.authenticationTokens.idToken;
      if (idToken == null)
        throw Exception("Erreur de récupération du token Google");

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) throw Exception("Utilisateur introuvable.");

      final uid = user.uid;

      // Vérifier si le user existe déjà dans Firestore
      final docRef = _firestore.collection('users').doc(uid);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        // Créer le nouvel utilisateur dans Firestore
        final newUser = UserModel(
          uid: uid,
          name: user.displayName ?? "Utilisateur",
          email: user.email ?? "",
          createdAt: DateTime.now(),
          photoURL: user.photoURL,
        );

        await docRef.set(newUser.toMap());
        // Charger le nouveau modèle
        if (context.mounted) {
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).fetchUserData(uid);
        }
      } else {
        // Charger les infos existantes
        if (context.mounted) {
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).fetchUserData(uid);
        }
      }

      _isLoading = false;
      notifyListeners();
    } on GoogleSignInException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur Google Sign-In : ${e.description}");
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur Firebase : ${e.message}");
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Erreur : ${e.toString()}");
    }
  }

  /// Déconnexion
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    // Vider les dépenses après logout
    Provider.of<ExpenseProvider>(context, listen: false).clearExpenses();

    // Vider les données du profil dans UserProvider
    Provider.of<UserProvider>(context, listen: false).clearUserData();

    notifyListeners();
  }

  //Supprimer son compte
  Future<void> deleteAccount(BuildContext context) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("Aucun utilisateur connecté");

      // Supprimer les données utilisateur dans Firestore
      await _firestore.collection('users').doc(currentUser.uid).delete();

      // Supprimer les dépenses liées
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );

      await expenseProvider.clearExpenses;

      // Vider les données du profil dans UserProvider
      Provider.of<UserProvider>(context, listen: false).clearUserData();

      // Supprimer le compte Firebase Auth
      await currentUser.delete();

      // Nettoyer localement
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          "Veuillez vous reconnecter avant de supprimer le compte.",
        );
      }
      throw Exception("Erreur lors de la suppression du compte : ${e.message}");
    } catch (e) {
      throw Exception("Erreur : $e");
    }
  }

  Future<void> checkAuthState() async {
    final user = _auth.currentUser;
    if (user != null) {
      // NOTE: Le chargement du profil doit être fait dans le SplashScreen
      // en utilisant Provider.of<UserProvider>(context).fetchUserData(user.uid);
      // avant de naviguer vers le MainDashboard.
    }
  }
}
