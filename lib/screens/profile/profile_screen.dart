import 'package:budgetflow/providers/user_provider.dart';
import 'package:budgetflow/screens/profile/edit_profil/edit_profile_screen.dart';
import 'package:budgetflow/utils/constants.dart';
import 'package:budgetflow/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUserData;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profil",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  // Navigation vers la page d’édition de profil
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.black, size: 26),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : user == null
            ? const Center(
                child: Text(
                  "Aucun utilisateur connecté",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(
                      name: user.name.toCapitalized(),
                      email: user.email,
                      imageUrl: user.photoURL,
                    ),
                    const SizedBox(height: 16),
                    const ProfileCard(),
                  ],
                ),
              ),
      ),
    );
  }
}
