import 'package:budgetflow/firebase_options.dart';
import 'package:budgetflow/providers/auth_provider.dart' as auth;
import 'package:budgetflow/providers/expense_provider.dart';
import 'package:budgetflow/providers/income_provider.dart';
import 'package:budgetflow/providers/project_provider.dart';
import 'package:budgetflow/providers/user_provider.dart';
import 'package:budgetflow/screens/splash_screen.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Désactive l'App Check en développement
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers
        ChangeNotifierProvider(create: (_) => auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
      ],
      child: MaterialApp(
        title: 'BudgetFlow',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFFF2F2F2),
          ),
          fontFamily: 'Outfit',

          // Configuration du thème pour les champs de texte
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),

          // Configuration du thème pour les boutons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
