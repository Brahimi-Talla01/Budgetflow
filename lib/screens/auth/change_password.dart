import 'package:budgetflow/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:budgetflow/utils/constants.dart';
import 'dart:async';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  /// Affichage de la boite de chargement
  Future<void> _showLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 4,
            ),
          ),
        ),
      ),
    );
  }

  /// Affichage du popup
  Future<void> _showSuccessPopup() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, color: AppColors.primary, size: 60),
              SizedBox(height: 20),
              Text(
                "Mot de passe modifié avec succès !",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    // Fermeture du popup et redirection
    await Future.delayed(const Duration(seconds: 2));
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    _goToLoginScreen();
  }

  void _goToLoginScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// Gère le clic sur "Continuer"
  Future<void> _handleContinue() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs.",
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Les mots de passe ne correspondent pas.",
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    //Loading
    await _showLoadingDialog();

    //delay
    await Future.delayed(const Duration(seconds: 2));

    // Fermeture du loading
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // Affiche la popup de succès
    await _showSuccessPopup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LogoText(),
              const SizedBox(height: 20),

              const Text(
                "Changez votre mot de passe",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              const Text(
                "Le nouveau mot de passe doit être différent de l'ancien.",
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Champ : Nouveau mot de passe
              TextField(
                controller: newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: "Nouveau mot de passe",
                  hintText: "Ex: 1234@g",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Champ : Confirmation
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: "Confirmez votre mot de passe",
                  hintText: "Ex: 1234@g",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continuer",
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

              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: _goToLoginScreen,
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

/// Logo
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
            const Text.rich(
              TextSpan(
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
