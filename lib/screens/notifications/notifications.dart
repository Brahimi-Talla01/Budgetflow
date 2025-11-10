import 'package:budgetflow/utils/constants.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Aucune notifications
            _buildEmptyNotificationState(),
          ],
        ),
      ),
    );
  }
}

// Pas de notifications
Widget _buildEmptyNotificationState() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(Icons.notifications, size: 64, color: AppColors.primary),
        const SizedBox(height: 16),
        const Text(
          "Aucune notifications !",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Vos notifications apparaîtront ici",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}
