import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';

class ExpenseItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String amount;
  final String date;
  final String category;
  final bool? isIncome;
  final String? id;
  final Color? iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseItem({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.date,
    this.id,
    this.category = "Alimentation",
    this.isIncome,
    this.iconColor,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ExpenseItem> createState() => _ExpenseItemState();
}

class _ExpenseItemState extends State<ExpenseItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    return ExpenseCategories.getColor(widget.category);
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ],
            ),
            // Titre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: _getCategoryColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.amount,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: (widget.isIncome ?? false)
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 20),

            // Option Modifier (désactivée pour l'instant)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: const Text(
                "Modifier",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                "Bientôt disponible. T'inquiète pas.",
                style: TextStyle(fontSize: 12),
              ),
              enabled: false, // Désactivé pour l'instant
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),

            // Option Supprimer
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              title: const Text(
                "Supprimer",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),

            const SizedBox(height: 10),

            // Bouton Annuler
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.lightGrey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? categoryColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isPressed ? 12 : 8,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône avec bordure colorée
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(14, 38, 208, 255),
                      const Color.fromARGB(14, 38, 208, 255),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color.fromARGB(36, 158, 158, 158),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: const Color.fromARGB(255, 184, 180, 180),
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Informations de la transaction
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Montant avec indicateur
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.amount,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Bouton trois points
                      GestureDetector(
                        onTap: () => _showOptionsMenu(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (widget.isIncome ?? false)
                          ? AppColors.success2.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (widget.isIncome ?? false)
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          size: 12,
                          color: (widget.isIncome ?? false)
                              ? AppColors.success2
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (widget.isIncome ?? false) ? "Revenu" : "Dépense",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: (widget.isIncome ?? false)
                                ? AppColors.success2
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
