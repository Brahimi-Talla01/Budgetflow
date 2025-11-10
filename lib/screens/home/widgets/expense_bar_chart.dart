import 'package:budgetflow/models/expense_model.dart';
import 'package:budgetflow/providers/expense_provider.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseChart extends StatelessWidget {
  final DateTime? filterMonth; // Pour filtrer par mois

  const ExpenseChart({super.key, this.filterMonth});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    // Filtrer les dépenses du mois actuel
    final currentMonth = filterMonth ?? DateTime.now();
    final monthExpenses = expenses.where((exp) {
      return exp.date.year == currentMonth.year &&
          exp.date.month == currentMonth.month &&
          exp.amount > 0;
    }).toList();

    if (monthExpenses.isEmpty) {
      return _buildEmptyState();
    }

    // Calculer les totaux par catégorie
    final categoryTotals = _calculateCategoryTotals(monthExpenses);

    // Calculer le total général
    final totalAmount = categoryTotals.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    // Créer les données pour le graphique
    final chartData = _createChartData(categoryTotals, totalAmount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getMonthName(currentMonth),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_formatAmount(totalAmount)} XAF",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${monthExpenses.length} dépenses",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Graphique
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(width: 50),
                // Pie Chart
                Expanded(
                  flex: 4,
                  child: PieChart(
                    PieChartData(
                      sections: chartData.map((data) {
                        return PieChartSectionData(
                          color: data['color'] as Color,
                          value: data['value'] as double,
                          title: "${data['percentage']}%",
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          badgeWidget: _buildBadge(
                            data['icon'] as IconData,
                            data['color'] as Color,
                          ),
                          badgePositionPercentageOffset: 1.3,
                        );
                      }).toList(),
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),

                const SizedBox(width: 50),

                // Légende verticale
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: chartData.map((data) {
                      return _buildLegendItem(
                        data['category'] as String,
                        data['amount'] as double,
                        data['color'] as Color,
                        data['percentage'] as int,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Calcul des totaux par catégorie
  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> totals = {};

    for (var expense in expenses) {
      if (totals.containsKey(expense.category)) {
        totals[expense.category] = totals[expense.category]! + expense.amount;
      } else {
        totals[expense.category] = expense.amount;
      }
    }

    return totals;
  }

  // Création des données du graphique
  List<Map<String, dynamic>> _createChartData(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    final chartData = <Map<String, dynamic>>[];

    // Trie des montants décroissant
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prise des 5 premières catégories
    final topCategories = sortedEntries.take(5);

    for (var entry in topCategories) {
      final percentage = ((entry.value / totalAmount) * 100).round();

      chartData.add({
        'category': entry.key,
        'amount': entry.value,
        'value': entry.value,
        'percentage': percentage,
        'color': ExpenseCategories.getColor(entry.key),
        'icon': ExpenseCategories.getIcon(entry.key),
      });
    }

    return chartData;
  }

  // Widget badge pour les icônes
  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  // Item de légende
  Widget _buildLegendItem(
    String category,
    double amount,
    Color color,
    int percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${_formatAmount(amount)} XAF",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucune dépense ce mois-ci",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Vos dépenses apparaîtront ici",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Formater le montant
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    }
    return amount.toStringAsFixed(0);
  }

  // Obtenir le nom du mois
  String _getMonthName(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return "Dépenses – ${months[date.month - 1]} ${date.year}";
  }
}
