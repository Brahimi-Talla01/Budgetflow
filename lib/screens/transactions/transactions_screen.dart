import 'dart:math' as math;
import 'package:budgetflow/providers/expense_provider.dart';
import 'package:budgetflow/providers/income_provider.dart';
import 'package:budgetflow/screens/home/widgets/read_expenses.dart';
import 'package:budgetflow/screens/home/widgets/read_incomes.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:budgetflow/widgets/expense/empty_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum TransactionType { revenue, expense }

enum TimeFilter { day, month, year }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType _selectedType = TransactionType.expense;
  TimeFilter _selectedTimeFilter = TimeFilter.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Transactions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boutons Revenu / Dépenses
            _buildTypeSelector(),

            const SizedBox(height: 20),

            // Filtres temporels
            _buildTimeFilters(),

            const SizedBox(height: 20),

            // Graphique
            _buildChart(),

            const SizedBox(height: 24),

            // Liste des transactions
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  // Sélecteur Revenu / Dépenses
  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              "Revenu",
              TransactionType.revenue,
              Icons.arrow_downward_rounded,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              "Dépenses",
              TransactionType.expense,
              Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type, IconData icon) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filtres temporels (Jour, Mois, Année)
  Widget _buildTimeFilters() {
    return Row(
      children: [
        _buildTimeFilterChip("Jours", TimeFilter.day),
        const SizedBox(width: 12),
        _buildTimeFilterChip("Mois", TimeFilter.month),
        const SizedBox(width: 12),
        _buildTimeFilterChip("Années", TimeFilter.year),
      ],
    );
  }

  Widget _buildTimeFilterChip(String label, TimeFilter filter) {
    final isSelected = _selectedTimeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // Graphique
  Widget _buildChart() {
    // Récupérer les bons providers selon le type
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);

    // Sélectionner les bonnes données
    final data = _selectedType == TransactionType.expense
        ? expenseProvider.expenses
        : incomeProvider.incomes;

    if (data.isEmpty) {
      return EmptyDataState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Période affichée
          Text(
            _getPeriodLabel(),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Graphique
          SizedBox(
            height: 200,
            child: _selectedType == TransactionType.expense
                ? _buildBarChart(data)
                : _buildLineChart(data),
          ),
        ],
      ),
    );
  }

  // Graphique en barres (pour les dépenses)
  Widget _buildBarChart(List data) {
    final chartData = _prepareChartData(data);

    final maxValue = chartData.values.isEmpty
        ? 0.0
        : chartData.values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 100.0 : maxValue * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
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
                    _getXAxisLabel(value.toInt()),
                    style: const TextStyle(
                      fontSize: 11,
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
              reservedSize: 40,
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
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: math.max(maxY > 0 ? maxY / 5 : 20.0, 0.00001),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value == 0 ? 0.1 : entry.value,
                gradient: LinearGradient(
                  colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Graphique en ligne (pour les revenus)
  Widget _buildLineChart(List data) {
    final chartData = _prepareChartData(data);

    final maxValue = chartData.values.isEmpty
        ? 0.0
        : chartData.values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 100.0 : maxValue * 1.2;

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${_formatAmount(spot.y)} XAF',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.entries
                .map(
                  (e) => FlSpot(e.key.toDouble(), e.value == 0 ? 0.0 : e.value),
                )
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
            ),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.success,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.3),
                  AppColors.success.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getXAxisLabel(value.toInt()),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatAmount(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: math.max(maxY > 0 ? maxY / 5 : 20.0, 0.00001),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // Liste des transactions
  Widget _buildTransactionsList() {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);

    // Sélectionner les bonnes données
    final List transactions = _selectedType == TransactionType.expense
        ? expenseProvider.expenses
        : incomeProvider.incomes;

    // Calcul du total
    final total = transactions.fold<double>(
      0,
      (sum, item) => sum + item.amount.abs(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedType == TransactionType.expense
                  ? "Mes dépenses"
                  : "Mes revenus",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              "${_selectedType == TransactionType.expense ? '-' : '+'} ${_formatAmount(total)} XAF",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _selectedType == TransactionType.expense
                    ? AppColors.error
                    : AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Liste
        transactions.isEmpty
            ? EmptyState(
                icon: _selectedType == TransactionType.expense
                    ? Icons.receipt_long_rounded
                    : Icons.account_balance_wallet_rounded,
                title: _selectedType == TransactionType.expense
                    ? "Aucune dépense"
                    : "Aucun revenu",
                message: _selectedType == TransactionType.expense
                    ? "Vos dépenses apparaîtront ici"
                    : "Vos revenus apparaîtront ici",
                color: _selectedType == TransactionType.expense
                    ? AppColors.error
                    : AppColors.success,
              )
            : (_selectedType == TransactionType.expense
                  ? ReadExpense()
                  : ReadIncome()),
      ],
    );
  }

  // Préparation des données du graphique (fonctionne pour expenses ET incomes)
  Map<int, double> _prepareChartData(List data) {
    final Map<int, double> chartData = {};

    if (_selectedTimeFilter == TimeFilter.day) {
      // 7 jours de la semaine
      for (int i = 0; i < 7; i++) {
        chartData[i] = 0;
      }
      for (var item in data) {
        final dayIndex = item.date.weekday - 1; // 0 = Lundi, 6 = Dimanche
        chartData[dayIndex] = (chartData[dayIndex] ?? 0) + item.amount.abs();
      }
    } else if (_selectedTimeFilter == TimeFilter.month) {
      // 12 mois
      for (int i = 1; i <= 12; i++) {
        chartData[i] = 0;
      }
      for (var item in data) {
        chartData[item.date.month] =
            (chartData[item.date.month] ?? 0) + item.amount.abs();
      }
    } else {
      // 5 années
      final currentYear = DateTime.now().year;
      for (int i = currentYear - 4; i <= currentYear; i++) {
        chartData[i] = 0;
      }
      for (var item in data) {
        chartData[item.date.year] =
            (chartData[item.date.year] ?? 0) + item.amount.abs();
      }
    }

    return chartData;
  }

  // Labels de l'axe X
  String _getXAxisLabel(int value) {
    if (_selectedTimeFilter == TimeFilter.day) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return value < days.length ? days[value] : '';
    } else if (_selectedTimeFilter == TimeFilter.month) {
      const months = [
        'J',
        'F',
        'M',
        'A',
        'M',
        'J',
        'J',
        'A',
        'S',
        'O',
        'N',
        'D',
      ];
      return value > 0 && value <= 12 ? months[value - 1] : '';
    } else {
      return value.toString();
    }
  }

  String _getPeriodLabel() {
    final now = DateTime.now();
    if (_selectedTimeFilter == TimeFilter.day) {
      return "7 derniers jours";
    } else if (_selectedTimeFilter == TimeFilter.month) {
      return "Janvier - Décembre ${now.year}";
    } else {
      return "${now.year - 4} - ${now.year}";
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }
    return amount.toStringAsFixed(0);
  }
}
