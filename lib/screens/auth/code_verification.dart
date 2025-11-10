import 'package:budgetflow/screens/auth/change_password.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';

class CodeVerification extends StatefulWidget {
  const CodeVerification({super.key});

  @override
  State<CodeVerification> createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification> {
  final TextEditingController _pin1Controller = TextEditingController();
  final TextEditingController _pin2Controller = TextEditingController();
  final TextEditingController _pin3Controller = TextEditingController();
  final TextEditingController _pin4Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pin1Controller.addListener(_checkCompletion);
    _pin2Controller.addListener(_checkCompletion);
    _pin3Controller.addListener(_checkCompletion);
    _pin4Controller.addListener(_checkCompletion);
  }

  @override
  void dispose() {
    _pin1Controller.dispose();
    _pin2Controller.dispose();
    _pin3Controller.dispose();
    _pin4Controller.dispose();
    super.dispose();
  }

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
                "Code vérifié avec succès !",
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
    _goToChangePassword();
  }

  // Fonction pour naviguer ver ForgetPassword
  void _goToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePassword()),
    );
  }

  bool _isCompleted = false;

  void _checkCompletion() {
    //Vérification si tous les champs contiennent exactement 1 caractère
    bool completed =
        _pin1Controller.text.length == 1 &&
        _pin2Controller.text.length == 1 &&
        _pin3Controller.text.length == 1 &&
        _pin4Controller.text.length == 1;

    //Mise à jour de l'état si la condition change
    if (completed != _isCompleted) {
      setState(() {
        _isCompleted = completed;
      });
    }
  }

  /// Gère le clic sur "Vérifier"
  Future<void> _handleVerify() async {
    //Loading
    await _showLoadingDialog();

    //delay
    await Future.delayed(const Duration(seconds: 1));

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // ----------- SECTION DU HAUT -----------
              Column(
                children: [
                  // ---------- LOGO ----------
                  LogoText(),

                  const SizedBox(height: 20),

                  // ---------- TITRE ----------
                  const Text(
                    "Entrez le code de vérification",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Vous avez reçu un code à l'adresse e-mail\nvotreadress@gmail.com",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  //----------- Pin Code ------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPinField(_pin1Controller, context),
                      _buildPinField(_pin2Controller, context),
                      _buildPinField(_pin3Controller, context),
                      _buildPinField(_pin4Controller, context),
                    ],
                  ),
                ],
              ),

              // ----------- ESPACE FLEXIBLE (pousse le bas vers le bas) -----------
              const Spacer(),

              // ----------- SECTION DU BAS -----------
              Column(
                children: [
                  // ---------- BOUTON VÉRIFICATION ----------
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isCompleted
                          ? () {
                              // Action de vérification
                              _handleVerify();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCompleted
                            ? AppColors.primary
                            : AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        //elevation: _isCompleted ? 0 : 0,
                      ),
                      child: const Text(
                        "Vérifier",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ---------- LIEN RENVOYER LE CODE ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Vous n'avez pas reçu de code ? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Logique de renvoie de code
                        },
                        child: const Text(
                          "Renvoyer",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildPinField(TextEditingController controller, BuildContext context) {
  return SizedBox(
    width: 60,
    height: 60,
    child: TextFormField(
      controller: controller,
      maxLength: 1,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      cursorColor: AppColors.primary,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
      decoration: InputDecoration(
        counterText: "",
        fillColor: AppColors.white,
        filled: true,

        hintText: '•',
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (value) {
        // Déplacer le focus au champ suivant si un chiffre est saisi
        if (value.isNotEmpty) {
          FocusScope.of(context).nextFocus();
        }
      },
    ),
  );
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
