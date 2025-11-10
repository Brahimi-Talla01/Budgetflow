import 'package:budgetflow/screens/auth/login_screen.dart';
import 'package:budgetflow/screens/onboarding/onboarding_data.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // Fonction appelée lorsque l'on arrive à la fin du guide
  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    // Naviguer vers la page de Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView avec les pages d'onboarding
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: onboardingPages
                  .map((page) => OnboardingPageContent(page: page))
                  .toList(),
            ),

            // Boutons en bas
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Indicateurs de pages
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: _currentPage == index ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bouton "Suivant"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPage < onboardingPages.length - 1) {
                          // await Future.delayed(
                          //   const Duration(milliseconds: 50),
                          // );
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == onboardingPages.length - 1
                            ? 'Commencer'
                            : 'Suivant',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bouton "Ignorer"
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Ignorer',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour le contenu de chaque page
class OnboardingPageContent extends StatelessWidget {
  final OnboardingData page;

  const OnboardingPageContent({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Logo
          LogoText(),

          const Spacer(),

          // Image
          Image.asset(page.image, height: 240, fit: BoxFit.contain),

          const SizedBox(height: 28),

          // Titre
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Roboto Mono',
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const Spacer(),
          const SizedBox(height: 190),
        ],
      ),
    );
  }
}
