import 'package:flutter/material.dart';

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
      selectedIndex: MainTab.values.indexOf(currentTab),
      onDestinationSelected: (index) => onChanged(MainTab.values[index]),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.tune_outlined), label: 'Output'),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          label: 'Files',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
