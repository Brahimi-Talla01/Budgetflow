import 'package:budgetflow/models/project_model.dart';
import 'package:budgetflow/providers/income_provider.dart';
import 'package:budgetflow/providers/project_provider.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:budgetflow/utils/helpers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddIncomeSheet extends StatefulWidget {
  const AddIncomeSheet({super.key});

  @override
  State<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<AddIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedIncome = IncomeSources.salaire;
  DateTime _selectedDate = DateTime.now();
  String? _selectedProjectId;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectSource() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choisir une source",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: IncomeSources.all.length,
              itemBuilder: (context, index) {
                final source = IncomeSources.all[index];
                final isSelected = source == _selectedIncome;
                final color = IncomeSources.getColor(source);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIncome = source;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IncomeSources.getIcon(source),
                          color: isSelected ? color : AppColors.textSecondary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          source,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      final incomeProvider = Provider.of<IncomeProvider>(
        context,
        listen: false,
      );
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );

      // --- MISE À JOUR DU PROJET ---
      if (_selectedProjectId != null) {
        // 1. Trouver le projet localement
        final selectedProject = projectProvider.projects.firstWhereOrNull(
          (p) => p.id == _selectedProjectId,
        );

        if (selectedProject != null) {
          // 2. Calculer la nouvelle somme cible
          final newTargetAmount = selectedProject.targetAmount + amount;

          // 3. Mettre à jour le montant du projet dans la base de données
          await projectProvider.updateProject(
            projectId: _selectedProjectId!,
            newTargetAmount: newTargetAmount,
          );
        }
      }

      // 4. Ajouter le revenu (avec le projectId)
      await incomeProvider.addIncome(
        amount: amount,
        source: _selectedIncome,
        description: _descriptionController.text,
        date: _selectedDate,
        projectId: _selectedProjectId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Revenu ajoutée avec succès !',
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(
        context,
        true,
      ); // Indiquer le succès du revenu et de la mise à jour
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e', textAlign: TextAlign.center),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectProject(List<Project> projects) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Associer à un projet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // OPTION PAR DÉFAUT (AUCUN PROJET)
            _buildProjectOption(
              icon: Icons.not_interested_rounded,
              color: AppColors.textSecondary,
              name: "Aucun projet",
              id: null,
            ),
            const Divider(height: 1, color: AppColors.lightGrey),

            // LISTE DES PROJETS
            ...projects.map(
              (project) => _buildProjectOption(
                icon: Icons.folder_special_rounded,
                color: project.color,
                name: project.name,
                id: project.id,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    final selectedProject = projects.firstWhereOrNull(
      (p) => p.id == _selectedProjectId,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header avec bouton fermer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ajouter un Revenu",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Champ montant (grand et centré)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Montant",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: "0",
                              hintStyle: TextStyle(
                                fontSize: 42,
                                color: AppColors.textSecondary.withOpacity(0.3),
                              ),
                              suffix: const Text(
                                " XAF",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              labelStyle: TextStyle(color: AppColors.primary),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Entrez un montant";
                              }
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return "Montant invalide";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sources
                    GestureDetector(
                      onTap: _selectSource,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ExpenseCategories.getColor(
                                  _selectedIncome,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                ExpenseCategories.getIcon(_selectedIncome),
                                color: ExpenseCategories.getColor(
                                  _selectedIncome,
                                ),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Sources",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedIncome,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Associé à un projet
                    GestureDetector(
                      onTap: () => _selectProject(projects),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (selectedProject?.color ??
                                            AppColors.primary)
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                selectedProject != null
                                    ? Icons.folder_special_rounded
                                    : Icons.work_off_rounded,
                                color:
                                    selectedProject?.color ?? AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Projet (Optionnel)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedProject?.name ?? "Aucun projet",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: "Ex: Salaire du mois",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Ajoutez une description";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Date",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateHelper.formatDateFr(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Bouton Enregistrer
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveIncome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Enregistrer",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget utilitaire pour afficher une option de projet
  Widget _buildProjectOption({
    required IconData icon,
    required Color color,
    required String name,
    required String? id,
  }) {
    final isSelected = _selectedProjectId == id;
    return ListTile(
      onTap: () {
        setState(() {
          _selectedProjectId = id;
        });
        Navigator.pop(context);
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
          : null,
    );
  }
}
