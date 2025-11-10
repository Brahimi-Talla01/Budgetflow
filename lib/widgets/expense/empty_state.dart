import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';

/// Widget d'état vide
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.15),
                        accentColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 60,
                    color: accentColor.withOpacity(0.6),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Titre
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Message
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),

          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 32),

            // Bouton d'action
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: ElevatedButton.icon(
                      onPressed: onButtonPressed,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(buttonText!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// État vide pour les dépenses
class EmptyExpensesState extends StatelessWidget {
  final VoidCallback? onAddPressed;

  const EmptyExpensesState({super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_rounded,
      title: "Aucune dépense",
      message: "Commencez à suivre vos dépenses\npour mieux gérer votre budget",
      buttonText: onAddPressed != null ? "Ajouter une dépense" : null,
      onButtonPressed: onAddPressed,
      color: AppColors.error,
    );
  }
}

/// État vide pour les revenus
class EmptyIncomesState extends StatelessWidget {
  final VoidCallback? onAddPressed;

  const EmptyIncomesState({super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.account_balance_wallet_rounded,
      title: "Aucun revenu",
      message:
          "Ajoutez vos sources de revenus\npour suivre votre situation financière",
      buttonText: onAddPressed != null ? "Ajouter un revenu" : null,
      onButtonPressed: onAddPressed,
      color: AppColors.success,
    );
  }
}

/// État vide pour les projets
class EmptyProjectsState extends StatelessWidget {
  final VoidCallback? onAddPressed;

  const EmptyProjectsState({super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.folder_special_rounded,
      title: "Aucun projet",
      message:
          "Créez votre premier projet pour\ncommencer à suivre vos dépenses",
      buttonText: onAddPressed != null ? "Créer un projet" : null,
      onButtonPressed: onAddPressed,
      color: const Color(0xFFFF6B6B),
    );
  }
}

/// État vide pour les données (graphiques)
class EmptyDataState extends StatelessWidget {
  const EmptyDataState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.bar_chart_rounded,
      title: "Pas encore de données",
      message:
          "Les statistiques apparaîtront\nune fois que vous aurez des transactions",
      color: AppColors.primary,
    );
  }
}

/// État vide pour les recherches
class EmptySearchState extends StatelessWidget {
  const EmptySearchState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.search_off_rounded,
      title: "Aucun résultat",
      message: "Essayez avec d'autres mots-clés\nou filtres de recherche",
      color: AppColors.textSecondary,
    );
  }
}

/// État d'erreur réseau
class NoInternetState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: "Pas de connexion",
      message: "Vérifiez votre connexion internet\net réessayez",
      buttonText: onRetry != null ? "Réessayer" : null,
      onButtonPressed: onRetry,
      color: AppColors.error,
    );
  }
}
