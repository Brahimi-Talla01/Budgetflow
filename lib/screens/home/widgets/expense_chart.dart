import 'package:budgetflow/providers/expense_provider.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseBarChart extends StatelessWidget {
  const ExpenseBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    if (expenseProvider.isLoading) {
      return _buildLoadingState();
    }

    if (expenses.isEmpty) {
      return _buildEmptyState();
    }

    // Calculer les dépenses des 6 derniers mois
    final monthlyData = _calculateMonthlyExpenses(expenses);

    if (monthlyData.isEmpty) {
      return _buildEmptyState();
    }

    final maxY = monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2;

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
        children: [
          Text(
            "6 derniers mois",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_formatAmount(rod.toY)} XAF',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getMonthLabel(value.toInt()),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatAmount(value),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _createBarGroups(monthlyData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateMonthlyExpenses(List expenses) {
    final Map<int, double> monthlyData = {};
    final now = DateTime.now();

    // Initialiser les 6 derniers mois
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = month.month;
      monthlyData[key] = 0.0;
    }

    // Calculer les totaux
    for (var expense in expenses) {
      if (expense.amount > 0) {
        final monthKey = expense.date.month;
        if (monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = monthlyData[monthKey]! + expense.amount;
        }
      }
    }

    return monthlyData;
  }

  List<BarChartGroupData> _createBarGroups(Map<int, double> data) {
    return data.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: AppColors.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    }).toList();
  }

  String _getMonthLabel(int month) {
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return months[month - 1];
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.primary,
              size: 50,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucune donnée pour le moment",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Commencez à ajouter des dépenses\npour voir vos statistiques ici.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
