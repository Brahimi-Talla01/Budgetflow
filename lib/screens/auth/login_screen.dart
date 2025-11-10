import 'package:budgetflow/providers/auth_provider.dart' as auth;
import 'package:budgetflow/screens/auth/forget_password.dart';
import 'package:budgetflow/screens/auth/signin_screen.dart';
import 'package:budgetflow/screens/main_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  bool _isLoadingGoogle = false;

  // Fonction pour naviguer ver SingIn page
  void _goToSingnInScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
    );
  }

  // Fonction pour naviguer vers ForgetPassword
  void _goToForgetPasswordScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgetPassword()),
    );
  }

  // Fonction pour naviguer vers Dashboad
  void _goToDashboadScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainDashboard()),
      (route) => false,
    );
  }

  /// Gère le clic sur "Continuer"
  void _logIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs",
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez entrer une adresse e-mail valide.",
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Le mot de passe doit contenir au moins 6 caractères",
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Démarrer un chronomètre pour simuler un délai minimum
    final stopwatch = Stopwatch()..start();
    const minDuration = Duration(seconds: 1);

    try {
      final authProvider = Provider.of<auth.AuthProvider>(
        context,
        listen: false,
      );

      // --- TENTATIVE DE CONNEXION ---
      await authProvider.login(
        context: context,
        email: email,
        password: password,
      );

      // Attendre que la durée minimum soit écoulée
      final elapsed = stopwatch.elapsed;
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
      stopwatch.stop();

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Vous êtes connecté !"),
            ],
          ),
          backgroundColor: AppColors.success2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      if (!mounted) return;
      _goToDashboadScreen(); // Redirection vers le tableau de bord
    } catch (e) {
      stopwatch.stop();
      setState(() => _isLoading = false);

      if (!mounted) return;

      // --- ERREURS SPÉCIFIQUES DE FIREBASE ---
      String errorMessage = "Une erreur inconnue est survenue.";
      Color errorColor = AppColors.error;

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
          case 'wrong-password':
            errorMessage = "Mot de passe ou e-mail incorrect.";
            break;
          case 'user-not-found':
            errorMessage = "Aucun utilisateur trouvé pour cet e-mail.";
            break;
          case 'user-disabled':
            errorMessage = "Votre compte a été désactivé.";
            break;
          case 'too-many-requests':
            errorMessage =
                "Tentatives de connexion excessives. Veuillez réessayer plus tard.";
            errorColor = AppColors.warning;
            break;
          case 'network-request-failed':
            errorMessage =
                "Aucune connexion Internet. Veuillez vérifier votre réseau.";
            errorColor = AppColors.error;
            break;
          default:
            errorMessage = "Erreur Firebase: ${e.code.replaceAll('-', ' ')}";
            break;
        }
      } else {
        // Autres exceptions
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      // Si le délai minimum n'a pas été atteint, on affiche un message d'attente
      if (stopwatch.elapsed < minDuration &&
          !(e is FirebaseAuthException &&
              e.code == 'network-request-failed')) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  //-------- CONNEXION AVEC UN COMPTE GOOGLE-------
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoadingGoogle = true);

    try {
      final authProvider = Provider.of<auth.AuthProvider>(
        context,
        listen: false,
      );

      // --- TENTATIVE DE CONNEXION ---
      await authProvider.signInWithGoogle(context);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connecté avec Google !", textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );

      _goToDashboadScreen(); // ta fonction de redirection
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------- LOGO ----------
              LogoText(),

              const SizedBox(height: 40),

              // ---------- TITRE ----------
              const Text(
                "Connexion à votre compte",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                "Gérez votre budget et suivez vos finances\nen toute simplicité.",
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // ---------- CHAMP EMAIL FINAL --------
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: "Adresse e-mail",
                  hintText: "votreadresse@gmail.com",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ---------- CHAMP MOT DE PASSE ----------
              TextField(
                controller: passwordController,
                obscureText: _obscureText,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  hintText: "votre mot de passe",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ---------- MOT DE PASSE OUBLIÉ ----------
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    //Naviguer vers Forget Password
                    _goToForgetPasswordScreen();
                  },
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ---------- BOUTON SE CONNECTER ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _logIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Se connecter"),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- SÉPARATEUR ----------
              Row(
                children: [
                  const Expanded(
                    child: Divider(thickness: 0.5, color: Colors.grey),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "ou connectez-vous avec",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(thickness: 0.5, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------- BOUTON GOOGLE ----------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingGoogle ? null : _signInWithGoogle,
                  icon: Image.asset(
                    'assets/images/google_logo.webp',
                    height: 22,
                  ),
                  label: _isLoadingGoogle
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "Google",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- LIEN CRÉER UN COMPTE ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Pas encore de compte ? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Naviguer vers la page d'inscription
                      _goToSingnInScreen();
                    },
                    child: const Text(
                      "Créer un compte",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoText extends StatelessWidget {
  const LogoText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo.png', height: 40),
        const SizedBox(width: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Roboto Mono',
                ),
                children: [
                  TextSpan(
                    text: 'Budget',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'Fl',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'o',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(
                    text: 'w',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 5,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
