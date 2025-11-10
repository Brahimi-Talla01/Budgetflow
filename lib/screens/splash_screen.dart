import 'package:budgetflow/providers/user_provider.dart';
import 'package:budgetflow/screens/onboarding/on_broading.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgetflow/screens/main_dashboard.dart';
import 'package:budgetflow/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Démarre la logique de navigation après le délai d'animation
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboarding()),
      );
      return;
    }

    // Vérifie si l’utilisateur Firebase est connecté
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      try {
        // Charger les données utilisateur Firestore via le provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchUserData(firebaseUser.uid);

        // Naviguer vers le dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      } catch (e) {
        debugPrint("Erreur de chargement du profil utilisateur: $e");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // Utilisateur déconnecté → aller à la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le reste de votre UI reste inchangé
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/logo.png'),
                width: 80,
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Roboto Mono',
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: 'Budget',
                      style: TextStyle(color: AppColors.backgroundDark),
                    ),
                    TextSpan(
                      text: 'Fl',
                      style: TextStyle(color: AppColors.backgroundDark),
                    ),
                    TextSpan(
                      text: 'o',
                      style: TextStyle(color: AppColors.white),
                    ),
                    TextSpan(
                      text: 'w',
                      style: TextStyle(color: AppColors.backgroundDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
