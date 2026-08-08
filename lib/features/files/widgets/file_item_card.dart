import 'package:flutter/material.dart';

import '../../../shared/widgets/file_card.dart';

class FileItemCard extends StatelessWidget {
  const FileItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FileCard(title: title, subtitle: subtitle, onTap: onTap);
  }
}
