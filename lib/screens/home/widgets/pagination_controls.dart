import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onPrevPage;
  final VoidCallback onNextPage;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.onPrevPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onPrevPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Previous',
              style: TextStyle(color: AppColors.white),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Text(
              'Page $currentPage',
              style: AppTextStyles.labelLarge,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onNextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Next',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}