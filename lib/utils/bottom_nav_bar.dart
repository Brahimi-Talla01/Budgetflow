// import 'package:flutter/material.dart';
// import 'package:budgetflow/utils/constants.dart';

// class BottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;

//   const BottomNavBar({
//     super.key,
//     required this.selectedIndex,
//     required this.onItemTapped,
//   });

//   final List<IconData> _icons = const [
//     Icons.home,
//     Icons.bar_chart,
//     Icons.folder,
//     Icons.person,
//   ];

//   // final List<String> _labels = const [
//   //   'Accueil',
//   //   'Dépenses',
//   //   'Projets',
//   //   'Profil',
//   // ];

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 28, left: 16, right: 16),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(40),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: List.generate(_icons.length, (index) {
//             final bool isSelected = selectedIndex == index;

//             return GestureDetector(
//               onTap: () => onItemTapped(index),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 250),
//                     curve: Curves.easeInOut,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? AppColors.primary
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                     child: Icon(
//                       _icons[index],
//                       color: isSelected ? Colors.white : Colors.black,
//                       size: 24,
//                     ),
//                   ),
//                   // const SizedBox(height: 4),
//                   // Text(
//                   //   _labels[index],
//                   //   style: TextStyle(
//                   //     fontSize: 12,
//                   //     fontWeight: isSelected
//                   //         ? FontWeight.bold
//                   //         : FontWeight.normal,
//                   //     color: isSelected ? AppColors.primary : Colors.black54,
//                   //   ),
//                   // ),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:budgetflow/utils/constants.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback? onAddPressed;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.onAddPressed,
  });

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.folder_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = const [
    'Accueil',
    'Dépenses',
    'Projets',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Barre de navigation
        Container(
          margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Items
              ...List.generate(4, (index) {
                return _buildNavItem(index);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icons[index],
              color: isSelected ? AppColors.primary : Colors.grey,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              child: Text(_labels[index]),
            ),
          ],
        ),
      ),
    );
  }
}
