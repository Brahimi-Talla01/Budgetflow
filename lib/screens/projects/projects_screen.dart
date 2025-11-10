import 'package:budgetflow/models/project_model.dart';
import 'package:budgetflow/providers/expense_provider.dart';
import 'package:budgetflow/providers/project_provider.dart';
import 'package:budgetflow/screens/projects/add_project_screen.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchUserProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final projects = projectProvider.projects;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Mes Projets",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddProjectSheet(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
      body: projectProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : projects.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () => projectProvider.fetchUserProjects(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques en haut
                    _buildStatsCard(projects, expenseProvider),

                    const SizedBox(height: 24),

                    // Section titre
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Projets actifs",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${projects.length} projet${projects.length > 1 ? 's' : ''}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Liste des projets
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        final spent = _calculateSpentAmount(
                          project.id,
                          expenseProvider,
                        );
                        return _buildProjectCard(project, spent, context);
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Nouveau projet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Stats card en haut
  Widget _buildStatsCard(
    List<Project> projects,
    ExpenseProvider expenseProvider,
  ) {
    final totalBudget = projects.fold<double>(
      0,
      (sum, project) => sum + project.targetAmount,
    );

    final totalSpent = projects.fold<double>(
      0,
      (sum, project) =>
          sum + _calculateSpentAmount(project.id, expenseProvider),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                "Budget Total",
                "${_formatAmount(totalBudget)} XAF",
                Icons.account_balance_wallet_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                "Dépensé",
                "${_formatAmount(totalSpent)} XAF",
                Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalBudget > 0
                  ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                  : 0,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${((totalBudget > 0 ? totalSpent / totalBudget : 0) * 100).toStringAsFixed(1)}% utilisé",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${totalBudget - totalSpent} XAF restant",
                // "${_formatAmount(totalBudget - totalSpent)} XAF restant",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Card de projet
  Widget _buildProjectCard(
    Project project,
    double spent,
    BuildContext context,
  ) {
    final progress = project.targetAmount > 0
        ? (spent / project.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = project.targetAmount - spent;

    return GestureDetector(
      onTap: () => _showProjectDetails(project, spent, context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: project.color.withOpacity(0.1),
              blurRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec nom et bouton options
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: project.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder_special_rounded,
                    color: project.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Créé le ${project.creationDate.day}/${project.creationDate.month}/${project.creationDate.year}",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showProjectOptions(project, context),
                  icon: const Icon(Icons.more_vert_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Montants
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dépensé",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_formatAmount(spent)} XAF",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: project.color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Budget",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_formatAmount(project.targetAmount)} XAF",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Barre de progression
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.lightGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(project.color),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${(progress * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: project.color,
                      ),
                    ),
                    Text(
                      remaining >= 0
                          ? "${_formatAmount(remaining)} XAF restant"
                          : "Dépassé de ${_formatAmount(remaining.abs())} XAF",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: remaining >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_special_rounded,
                size: 80,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Aucun projet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Créez votre premier projet pour\ncommencer à suivre vos dépenses",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddProjectSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text("Créer un projet"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calculer le montant dépensé pour un projet
  double _calculateSpentAmount(String projectId, ExpenseProvider provider) {
    return provider.expenses
        .where((exp) => exp.projectId == projectId && exp.amount > 0)
        .fold<double>(0, (sum, exp) => sum + exp.amount);
  }

  // Formater montant
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }
    return amount.toStringAsFixed(0);
  }

  // Afficher le sheet d'ajout de projet
  void _showAddProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return const AddProjectSheet();
      },
    );
  }

  // Afficher les détails d'un projet
  void _showProjectDetails(
    Project project,
    double spent,
    BuildContext context,
  ) {
    // Implémenter
  }

  // Afficher les options d'un projet
  void _showProjectOptions(Project project, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.only(
            left: 16.0,
            bottom: 24.0,
            right: 16.0,
            top: 10.0,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Occupe l'espace minimal requis
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
              // --- OPTION MODIFIER ---
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
                title: const Text("Modifier le projet"),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  // _showEditProjectSheet(context, project);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Pas encore disponible.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.lightGrey),

              // --- OPTION SUPPRIMER ---
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
                  "Supprimer le projet",
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _confirmAndDeleteProject(context, project);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Gère la confirmation et la suppression finale
void _confirmAndDeleteProject(BuildContext context, Project project) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );

      return AlertDialog(
        title: const Text("Supprimer le projet ?"),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer le projet '${project.name}' ? Cette action est irréversible et les dépenses associées ne seront plus liées.",
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                //Suppression réelle via le provider
                await projectProvider.deleteProject(project.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Projet supprimé avec succès !"),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Échec de la suppression: ${e.toString()}"),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      );
    },
  );
}
