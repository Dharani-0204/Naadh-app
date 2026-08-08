import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/file_item_card.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  static const files = <(String, String)>[
    ('Physics — Chapter 3', 'Today · 12 pages · 3.2 MB'),
    ('Machine Learning Notes', 'Yesterday · 28 pages · 8.7 MB'),
    ('Roman Empire Summary', 'Aug 6 · 8 pages · 2.1 MB'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  hintText: 'Search files',
                  leading: const Icon(Icons.search),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_alt_outlined),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Documents'),
                selected: true,
                onSelected: (_) {},
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Audio'),
                selected: false,
                onSelected: (_) {},
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Favorites'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: files.isEmpty
              ? const EmptyState(
                  title: 'No files yet',
                  subtitle:
                      'Captured documents and generated audio will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = files[index];
                    return FileItemCard(title: item.$1, subtitle: item.$2);
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemCount: files.length,
                ),
        ),
      ],
    );
  }
}
