import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum MainTab { home, output, files, profile }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.onChanged,
  });

  final MainTab currentTab;
  final ValueChanged<MainTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.lilac,         // Purple/lilac highlight behind selected icon
      selectedIndex: MainTab.values.indexOf(currentTab),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      animationDuration: const Duration(milliseconds: 300),
      onDestinationSelected: (index) => onChanged(MainTab.values[index]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: AppColors.purple),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune, color: AppColors.purple),
          label: 'Output',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder, color: AppColors.purple),
          label: 'Files',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.purple),
          label: 'Profile',
        ),
      ],
    );
  }
}
