import 'package:budgetflow/providers/auth_provider.dart';
import 'package:budgetflow/screens/auth/login_screen.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildRow(
            context,
            Icons.location_on,
            "Localisation",
            "Pas défini",
            onTap: () {},
          ),
          const Divider(),
          _buildRow(
            context,
            Icons.settings,
            "Paramètres",
            "Préférences de compte",
            onTap: () {},
          ),
          const Divider(),
          _buildRow(
            context,
            Icons.logout,
            "Déconnexion",
            "",
            color: Colors.red,
            trailing: false,
            onTap: () => _confirmAction(context, actionType: 'logout'),
          ),
          const Divider(),
          _buildRow(
            context,
            Icons.delete_forever_rounded,
            "Supprimer mon compte",
            "",
            color: Colors.red,
            trailing: false,
            onTap: () => _confirmAction(context, actionType: 'delete'),
          ),
        ],
      ),
    );
  }

  /// Générateur de lignes
  Widget _buildRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    Color? color,
    bool trailing = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: trailing
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54)
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Fonction générique pour gérer Déconnexion / Suppression
  Future<void> _confirmAction(
    BuildContext context, {
    required String actionType,
  }) async {
    final bool isDelete = actionType == 'delete';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isDelete ? 'Supprimer le compte' : 'Confirmer la déconnexion',
        ),
        content: Text(
          isDelete
              ? 'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible.'
              : 'Voulez-vous vraiment vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              isDelete ? 'Supprimer' : 'Déconnexion',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Affiche un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (isDelete) {
        await authProvider.deleteAccount(context);
      } else {
        await authProvider.logout(context);
      }

      // Fermer le loader
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDelete ? 'Compte supprimé avec succès' : 'Déconnecté avec succès',
            textAlign: TextAlign.center,
          ),
        ),
      );

      // Rediriger vers login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
    }
  }
}
