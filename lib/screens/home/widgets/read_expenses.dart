import 'package:budgetflow/screens/home/widgets/expense_item.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetflow/providers/expense_provider.dart';

class ReadExpense extends StatelessWidget {
  const ReadExpense({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    if (expenseProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          backgroundColor: AppColors.white,
          color: AppColors.primary,
        ),
      );
    }

    if (expenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                "Aucune dépense enregistrée",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Commencez à ajouter vos dépenses\npour les suivre ici",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final exp = expenses[index];
        final itemIcon = ExpenseCategories.getIcon(exp.category);

        return ExpenseItem(
          icon: itemIcon,
          title: exp.description,
          amount: "${exp.amount >= 0 ? '-' : '+'} ${exp.amount.abs()} XAF",
          date: "${exp.date.day}/${exp.date.month}/${exp.date.year}",
          category: exp.category,
          isIncome: exp.amount < 0,
          onTap: () {
            // Action au tap (voir détails par exemple)
          },
          onDelete: () {
            _showDeleteConfirmationDialog(context, exp.id, expenseProvider);
          },
          onEdit: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Modification bientôt disponible"),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    String expenseId,
    ExpenseProvider expenseProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text("Supprimer ?", style: TextStyle(fontSize: 20)),
            ],
          ),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer cette transaction ? Cette action est irréversible.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            // Bouton ANNULER
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Annuler",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Bouton SUPPRIMER
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                try {
                  await expenseProvider.deleteExpense(expenseId);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text("Transaction supprimée avec succès"),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text("Échec de la suppression: $e")),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Supprimer",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
