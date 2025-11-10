import 'package:budgetflow/providers/project_provider.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddProjectSheet extends StatefulWidget {
  const AddProjectSheet({super.key});

  @override
  State<AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends State<AddProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  Color _selectedColor = const Color(0xFFFF6B6B);
  bool _isLoading = false;

  final List<Color> _availableColors = [
    const Color(0xFFFF6B6B), // Rouge
    const Color(0xFF4ECDC4), // Turquoise
    const Color(0xFFFFE66D), // Jaune
    const Color(0xFF95E1D3), // Vert menthe
    const Color(0xFFA8E6CF), // Vert clair
    const Color(0xFFFFD3B6), // Orange clair
    const Color(0xFFFFAAA5), // Rose
    const Color(0xFF26D0FF), // Bleu (primary)
    const Color(0xFF242C47), // Bleu foncé
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );

      await projectProvider.addProject(
        name: _nameController.text.trim(),
        targetAmount: double.parse(_budgetController.text),
        color: _selectedColor,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Projet créé avec succès !"),
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
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nouveau projet",
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
                    // Nom du projet
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
                            "Nom du projet",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: "Ex: Fête de fin d'année",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Entrez un nom de projet";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Budget
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
                            "Budget total",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: "0",
                              hintStyle: TextStyle(
                                fontSize: 24,
                                color: AppColors.textSecondary.withOpacity(0.3),
                              ),
                              suffix: const Text(
                                " XAF",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Entrez un budget";
                              }
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return "Budget invalide";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sélection de couleur
                    const Text(
                      "Couleur du projet",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableColors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bouton Créer
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
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
                          "Créer le projet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
}
