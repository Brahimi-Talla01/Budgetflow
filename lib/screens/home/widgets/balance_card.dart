import 'package:budgetflow/providers/expense_provider.dart';
import 'package:budgetflow/providers/income_provider.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:budgetflow/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    // Calculs
    final totalIncome = incomeProvider.incomes.fold<double>(
      0.0,
      (sum, income) => sum + income.amount,
    );

    final totalExpenses = expenseProvider.expenses.fold<double>(
      0.0,
      (sum, expense) => sum + (expense.amount > 0 ? expense.amount : 0),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Motifs
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec titre et bouton visibilité
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total des Dépenses & Revenus",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      icon: Icon(
                        _isVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),

                // Ligne de séparation
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Statistiques en grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.arrow_downward_rounded,
                        label: "Revenus",
                        amount: DateHelper.formatAmount(totalIncome),
                        color: Colors.green,
                        isVisible: _isVisible,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.arrow_upward_rounded,
                        label: "Dépenses",
                        amount: DateHelper.formatAmount(totalExpenses),
                        color: Colors.red,
                        isVisible: _isVisible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;
  final bool isVisible;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isVisible ? amount : "••••",
              key: ValueKey(isVisible),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
