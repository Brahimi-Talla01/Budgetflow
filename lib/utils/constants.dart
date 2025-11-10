import 'package:flutter/material.dart';

// COULEURS DE MON APP
class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF26D0FF); // Bleu clair principal
  static const Color darkBackground = Color(0xFF242C47); // Fond sombre
  static const Color lightGrey = Color(0xFFF2F2F2); // Gris clair
  static const Color white = Color(0xFFFFFFFF); // Blanc

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF242C47);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFFFFFFF);

  // Couleurs de fond
  static const Color backgroundLight = Color(0xFFF2F2F2);
  static const Color backgroundDark = Color(0xFF242C47);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Ombres et bordures
  static const Color shadow = Color(0x1A000000);
  static const Color border = Color(0xFFE0E0E0);
  static const Color success = primary;
  static const Color success2 = Color(0xFF34D399);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFA726);
}

// DIMENSIONS ET ESPACEMENTS
class AppSizes {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Tailles d'icônes
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // Tailles de boutons
  static const double buttonHeight = 50.0;
  static const double buttonHeightSmall = 40.0;
}

// TEXTES CONSTANTS
class AppStrings {
  // Nom de l'application
  static const String appName = 'BudgetFlow';

  // Authentification
  static const String login = 'Connexion';
  static const String register = 'Inscription';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String forgotPassword = 'Mot de passe oublié ?';
  static const String noAccount = 'Pas encore de compte ?';
  static const String alreadyHaveAccount = 'Déjà un compte ?';

  // Navigation
  static const String dashboard = 'Tableau de bord';
  static const String expenses = 'Dépenses';
  static const String projects = 'Projets';
  static const String profile = 'Profil';

  // Dépenses
  static const String addExpense = 'Ajouter une dépense';
  static const String amount = 'Montant';
  static const String category = 'Catégorie';
  static const String description = 'Description';
  static const String date = 'Date';
  static const String save = 'Enregistrer';
  static const String cancel = 'Annuler';

  // Projets
  static const String addProject = 'Nouveau projet';
  static const String projectName = 'Nom du projet';
  static const String budget = 'Budget';
  static const String duration = 'Durée (jours)';
  static const String progress = 'Progression';

  // Messages
  static const String success = 'Succès';
  static const String error = 'Erreur';
  static const String loading = 'Chargement...';
  static const String noData = 'Aucune donnée disponible';
}

//CATÉGORIES DE DÉPENSES
class ExpenseCategories {
  static const String alimentation = 'Alimentation';
  static const String transport = 'Transport';
  static const String loisirs = 'Loisirs';
  static const String sante = 'Santé';
  static const String education = 'Éducation';
  static const String logement = 'Logement';
  static const String shopping = 'Shopping';
  static const String autres = 'Autres';

  static const List<String> all = [
    alimentation,
    transport,
    loisirs,
    sante,
    education,
    logement,
    shopping,
    autres,
  ];

  // Icônes associées aux catégories
  static IconData getIcon(String category) {
    switch (category) {
      case alimentation:
        return Icons.restaurant;
      case transport:
        return Icons.directions_car;
      case loisirs:
        return Icons.sports_esports;
      case sante:
        return Icons.local_hospital;
      case education:
        return Icons.school;
      case logement:
        return Icons.home;
      case shopping:
        return Icons.shopping_bag;
      case autres:
      default:
        return Icons.category;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case alimentation:
        return const Color(0xFFFF6B6B);
      case transport:
        return const Color(0xFF4ECDC4);
      case loisirs:
        return const Color(0xFFFFE66D);
      case sante:
        return const Color(0xFF95E1D3);
      case education:
        return const Color(0xFFA8E6CF);
      case logement:
        return const Color(0xFFFFD3B6);
      case shopping:
        return const Color(0xFFFFAAA5);
      case autres:
      default:
        return const Color(0xFFB8B8B8);
    }
  }
}

// SOURCES DE REVENUS
class IncomeSources {
  // --- Noms des Sources de Revenus ---
  static const String salaire = 'Salaire';
  static const String freelance = 'Freelance';
  static const String investissements = 'Investissements';
  static const String cadeaux = 'Cadeaux';
  static const String vente = 'Vente';
  static const String bonus = 'Bonus';
  static const String autres = 'Autres';

  // --- Liste complète des sources ---
  static const List<String> all = [
    salaire,
    freelance,
    investissements,
    cadeaux,
    vente,
    bonus,
    autres,
  ];

  // --- Icônes associées aux sources ---
  static IconData getIcon(String source) {
    switch (source) {
      case salaire:
        return Icons.account_balance;
      case freelance:
        return Icons.laptop_mac;
      case investissements:
        return Icons.trending_up;
      case cadeaux:
        return Icons.card_giftcard;
      case vente:
        return Icons.storefront;
      case bonus:
        return Icons.emoji_events;
      case autres:
      default:
        return Icons.money;
    }
  }

  // --- Couleurs associées aux sources ---
  static Color getColor(String source) {
    switch (source) {
      case salaire:
        return const Color(0xFF6A994E); // Vert foncé
      case freelance:
        return const Color(0xFFC7EF00); // Vert citron
      case investissements:
        return const Color(0xFF4A90E2); // Bleu vif
      case cadeaux:
        return const Color(0xFFF78888); // Rose clair
      case vente:
        return const Color(0xFF94D2BD); // Vert eau
      case bonus:
        return const Color(0xFFFFB703); // Ambre/Jaune
      case autres:
      default:
        return const Color(0xFF8D99AE); // Gris neutre
    }
  }
}

// DEVISES
class Currencies {
  static const String xaf = 'XAF';
}

// CLÉS DE COLLECTIONS FIRESTORE
class FirestoreCollections {
  static const String users = 'users';
  static const String expenses = 'expenses';
  static const String projects = 'projects';
}

// STYLES DE TEXTE
class AppTextStyles {
  // Titres
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Corps de texte
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Boutons
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

class AppConfig {
  static const String defaultCurrency = Currencies.xaf;
  static const int maxExpenseHistory = 100;
  static const Duration animationDuration = Duration(milliseconds: 300);
}
