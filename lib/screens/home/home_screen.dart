import 'package:budgetflow/providers/expense_provider.dart';
import 'package:budgetflow/providers/income_provider.dart';
import 'package:budgetflow/providers/user_provider.dart';
import 'package:budgetflow/screens/home/widgets/add_expense_sheet.dart';
import 'package:budgetflow/screens/home/widgets/add_income_sheet.dart';
import 'package:budgetflow/screens/home/widgets/balance_card.dart';
import 'package:budgetflow/screens/home/widgets/expense_bar_chart.dart';
import 'package:budgetflow/screens/home/widgets/expense_chart.dart';
import 'package:budgetflow/screens/home/widgets/read_expenses.dart';
import 'package:budgetflow/screens/home/widgets/read_incomes.dart';
import 'package:budgetflow/screens/notifications/notifications.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:budgetflow/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // État du menu flottant
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ExpenseProvider>(context, listen: false).fetchUserExpenses();
      Provider.of<IncomeProvider>(context, listen: false).fetchUserIncomes();
    });
  }

  // Fonction pour basculer l'état du menu
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  // Fonction pour les revenus
  void _showAddIncomeSheet() {
    if (_isMenuOpen) {
      _toggleMenu();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddIncomeSheet(),
    ).then((result) {
      // Récupérer les données retournées
      if (result != null) {
        // Traiter les données de la dépense
        final amount = result['amount'];
        final source = result['source'];
        final description = result['description'];
        final date = result['date'];

        // Sauvegarder dans Firebase
        print(
          "Nouvelle dépense: $amount XAF - $source - $description Effetuée le : $date",
        );

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  "Revenu ajoutée avec succès !",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  // Ajouter une dépense
  void _showAddExpenseSheet() {
    if (_isMenuOpen) {
      _toggleMenu();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExpenseSheet(),
    ).then((result) {
      // Récupérer les données retournées
      if (result != null) {
        // Traiter les données de la dépense
        final amount = result['amount'];
        final category = result['category'];
        final description = result['description'];
        final date = result['date'];

        // Sauvegarder dans Firebase
        print(
          "Nouvelle dépense: $amount XAF - $category - $description Effetuée le : $date",
        );

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Dépense ajoutée avec succès !"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUserData;

    // Le contenu principal de la page
    final mainContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // 1. Carte de Solde
          BalanceCard(),

          SizedBox(height: 20),
          // 2. Section des Statistiques
          MonthlyExpenseStatistics(),

          SizedBox(height: 20),

          // 3. Section Liste des Dépenses
          ExpenseListSection(),

          //4. Section Liste des Revenus
          IncomeListSection(),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 64,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            user != null
                ? Text(
                    "Hello ${user.name.toTitleCase()}",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Text(
                    "Hello",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const Text(
              "Organise mieux ton budget ici.",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.black,
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
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
            ),
          ),
        ],
      ),

      // Body
      body: Stack(
        children: [
          //1. Contenu principal
          mainContent,

          //2. Overlay pour fermer le menu
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu, // Ferme le menu au clic
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),

          // 3. Boutons du Menu et FAB principal
          Positioned(
            right: 16,
            bottom: 16,
            // Affiche le menu OU le FAB principal
            child: _buildFABMenuContent(context),
          ),
        ],
      ),
    );
  }

  // Affiche le Menu OU le FAB principal
  Widget _buildFABMenuContent(BuildContext context) {
    if (_isMenuOpen) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bouton "Revenus"
          _buildWideFABItem(
            label: "Revenus",
            icon: Icons.attach_money_rounded,
            onTap: _showAddIncomeSheet,
          ),
          const SizedBox(height: 8),

          // Bouton "Dépense"
          _buildWideFABItem(
            label: "Dépense",
            icon: Icons.shopping_cart_rounded,
            onTap: _showAddExpenseSheet,
          ),
          const SizedBox(height: 16),

          // Bouton principal
          _buildMainFAB(),
        ],
      );
    } else {
      // Si le menu n'est PAS ouvert, on retourne uniquement le FAB principal
      return _buildMainFAB();
    }
  }

  Widget _buildMainFAB() {
    return FloatingActionButton(
      onPressed: _toggleMenu,
      backgroundColor: AppColors.primary,
      child: Icon(
        // L'icône est X si le menu est ouvert, + sinon.
        _isMenuOpen ? Icons.close : Icons.add,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildWideFABItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 60,
      width: 180,
      child: FloatingActionButton.extended(
        heroTag: label,
        onPressed: onTap,
        backgroundColor: Colors.blue[50],
        label: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        icon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class MonthlyExpenseStatistics extends StatelessWidget {
  const MonthlyExpenseStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dépenses Mensuels",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
          ),
        ),
        SizedBox(height: 10),
        // Widget du graphique barchat
        ExpenseBarChart(),
        SizedBox(height: 20),
        // Widget du graphique piechart
        ExpenseChart(),
      ],
    );
  }
}

class ExpenseListSection extends StatelessWidget {
  const ExpenseListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Mes dépenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                // Naviguer vers la page complète des dépenses
              },
              child: Text(
                "Voir plus",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Widget pour les dépenses
        const ReadExpense(),
      ],
    );
  }
}

// Liste des revenus
class IncomeListSection extends StatelessWidget {
  const IncomeListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Mes Revenus",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                // Naviguer vers la page complète des dépenses
              },
              child: Text(
                "Voir plus",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Widget pour les revenus
        const ReadIncome(),
      ],
    );
  }
}
