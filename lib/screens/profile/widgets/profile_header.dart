import 'package:budgetflow/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:budgetflow/utils/constants.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.white,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            name.toTitleCase(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
