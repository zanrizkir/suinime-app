import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pustaka masih kosong',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
