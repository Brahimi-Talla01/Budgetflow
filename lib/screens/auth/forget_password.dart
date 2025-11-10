// import 'package:budgetflow/screens/auth/code_verification.dart';
import 'package:budgetflow/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgetflow/utils/constants.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _passwordReset() async {
    final email = _emailController.text.trim();

    // Vérification des champs
    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Erreur"),
          content: Text("Veuillez entrer votre adresse e-mail."),
        ),
      );
      return;
    }

    // Vérification du format d'email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Adresse e-mail invalide"),
          content: Text("Veuillez entrer une adresse e-mail valide."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Lien envoyé"),
            content: Text(
              "Un lien de réinitialisation du mot de passe a été envoyé à l'adresse : $email.\n"
              "Veuillez vérifier votre boîte mail.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      String message;
      setState(() => _isLoading = false);

      switch (e.code) {
        case "invalid-email":
          message = "L'adresse e-mail n'est pas valide.";
          break;
        case "user-not-found":
          message = "Aucun utilisateur trouvé avec cette adresse e-mail.";
          break;
        case "missing-email":
          message = "Veuillez entrer une adresse e-mail.";
          break;
        default:
          message = "Une erreur s'est produite : ${e.message}";
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Erreur"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Erreur inattendue"),
            content: Text("Une erreur s'est produite : $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  // Fonction pour naviguer ver ForgetPassword
  // void _goToCheckCodeVerification() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const CodeVerification()),
  //   );
  // }

  // Fonction pour revenir vers SingIn page
  void _goToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------- LOGO ----------
              LogoText(),

              const SizedBox(height: 20),

              // ---------- TITRE ----------
              const Text(
                "Mot de passe oublié ?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                "Entrez votre adresse e-mail pour changer\nvotre mot de passe.",
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Image
              Image.asset('assets/images/reset00.png', height: 240),

              // ---------- CHAMP EMAIL ----------
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Adresse e-mail",
                  hintText: "votreadress@gmail.com",

                  prefixIcon: const Icon(Icons.email_outlined),

                  labelStyle: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),

                  filled: true,
                  fillColor: AppColors.white,

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ---------- BOUTON SE CONTINUER ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _passwordReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                      : const Text(
                          "Envoyer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Outfit',
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- BOUTON ANNULER ----------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    // Action de connexion
                    _goToLoginScreen();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
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
