import 'package:budgetflow/providers/user_provider.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.currentUserData?.name ?? "";
  }

  Future<void> _saveChanges() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Le nom ne peut pas être vide.",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    if (newName.trim() == _nameController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text(
            "Aucune modification détectée.",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserName(newName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nom mis à jour avec succès !",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : ${e.toString()}",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUserData;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: const Text(
          "Modifier le profil",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo de profil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Champ du nom
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nom complet",
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                hintText: "Entre ton nom complet",
              ),
            ),
            const SizedBox(height: 40),

            // Bouton Enregistrer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Enregistrer",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
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
