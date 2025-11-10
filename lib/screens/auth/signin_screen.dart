import 'package:budgetflow/providers/auth_provider.dart';
import 'package:budgetflow/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fonction pour naviguer vers Login page
  void _goToLoginScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _signUp() async {
    // Validation des champs
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le mot de passe doit contenir au moins 6 caractères"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signUp(
        context: context,
        name: name,
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte créé avec succès !"),
          backgroundColor: Colors.green,
        ),
      );

      // Attendre 1 seconde avant de rediriger
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
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
              const LogoText(),

              const SizedBox(height: 20),

              // ---------- TITRE ----------
              const Text(
                "Créer un compte",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                "Inscrivez-vous pour mieux gérer vos\ndépenses et suivre vos finances.",
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // ---------- CHAMP NOM COMPLET ----------
              TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Nom complet",
                  hintText: "Votre nom",
                  prefixIcon: const Icon(Icons.person),
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 16),

              // ---------- CHAMP EMAIL ----------
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Adresse e-mail",
                  hintText: "votreadresse@gmail.com",
                  prefixIcon: const Icon(Icons.email_outlined),
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 16),

              // ---------- CHAMP MOT DE PASSE ----------
              TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  hintText: "Minimum 6 caractères",
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
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- BOUTON CRÉER UN COMPTE ----------
              SizedBox(
                width: double.infinity,
                // height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                      "ou inscrivez-vous avec",
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
                // height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Connexion Google - Bientôt disponible",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  icon: Image.asset(
                    'assets/images/google_logo.webp',
                    height: 22,
                  ),
                  label: const Text(
                    "Google",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- LIEN SE CONNECTER ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Vous avez déjà un compte ? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: _goToLoginScreen,
                    child: const Text(
                      "Se connecter",
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
