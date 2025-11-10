import 'package:budgetflow/providers/income_provider.dart';
import 'package:budgetflow/screens/home/widgets/expense_item.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:budgetflow/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReadIncome extends StatelessWidget {
  const ReadIncome({super.key});

  @override
  Widget build(BuildContext context) {
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final incomes = incomeProvider.incomes;

    // LOGIQUE DE CHARGEMENT
    if (incomeProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          backgroundColor: AppColors.white,
          color: AppColors.success,
        ),
      );
    }

    // LOGIQUE D'ÉTAT VIDE
    if (incomes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on_outlined,
                size: 64,
                color: AppColors.success,
              ),
              SizedBox(height: 16),
              Text(
                "Aucun revenu enregistré",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Commencez à ajouter vos revenus\npour les suivre ici",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // LISTE DES REVENUS
    return ListView.builder(
      itemCount: incomes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final inc = incomes[index];

        // Récupérer l'icône et la couleur depuis IncomeSources
        final itemIcon = IncomeSources.getIcon(inc.source);
        final itemColor = IncomeSources.getColor(inc.source);

        return ExpenseItem(
          icon: itemIcon,
          title: inc.description.isNotEmpty ? inc.description : inc.source,
          amount: "+ ${DateHelper.formatAmount(inc.amount)}",
          date: DateHelper.formatDateFr(inc.date),
          category: inc.source,
          isIncome: true,
          iconColor: itemColor,
          onTap: () {
            // Action au tap (voir détails par exemple)
          },
          onDelete: () {
            _showDeleteConfirmationDialog(context, inc.id, incomeProvider);
          },
          onEdit: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Modification bientôt disponible"),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      },
    );
  }

  // DIALOGUE DE CONFIRMATION DE SUPPRESSION
  void _showDeleteConfirmationDialog(
    BuildContext context,
    String incomeId,
    IncomeProvider incomeProvider,
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
            "Êtes-vous sûr de vouloir supprimer ce revenu ? Cette action est irréversible.",
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
                  await incomeProvider.deleteIncome(incomeId);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text("Revenu supprimé avec succès"),
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
