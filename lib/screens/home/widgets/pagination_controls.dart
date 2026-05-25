import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onPrevPage;
  final VoidCallback onNextPage;
  final int? totalPages;
  final bool? hasNextPage;
  final Function(int)? onPageSelected;

  /// Creates pagination controls with numbered page buttons.
  ///
  /// Parameters:
  /// - currentPage: Current page number (1-indexed)
  /// - onPrevPage: Callback for previous page (null = disabled)
  /// - onNextPage: Callback for next page
  /// - totalPages: Total number of pages (optional, shows all if small)
  /// - hasNextPage: Whether more pages exist (optional, disables Next if false)
  /// - onPageSelected: Callback when a specific page is clicked (optional)
  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.onPrevPage,
    required this.onNextPage,
    this.totalPages,
    this.hasNextPage,
    this.onPageSelected,
  });

  List<Object> _getVisibleItems() {
    final lastPage = totalPages ?? currentPage;
    if (lastPage <= 0) return const [1];
    if (lastPage <= 7) {
      return List.generate(lastPage, (i) => i + 1);
    }

    if (currentPage <= 3) {
      return [1, 2, 3, '...', lastPage];
    }
    if (currentPage >= lastPage - 2) {
      return [1, '...', lastPage - 2, lastPage - 1, lastPage];
    }
    return [
      1,
      '...',
      currentPage - 1,
      currentPage,
      currentPage + 1,
      '...',
      lastPage,
    ];
  }

  Widget _buildPageButton(BuildContext context, int page, VoidCallback onTap) {
    final isCurrentPage = page == currentPage;
    final isSmallScreen = Responsive.isMobile(context);
    final buttonSize = isSmallScreen ? 32.0 : 40.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: isCurrentPage ? AppColors.primary : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isCurrentPage
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isCurrentPage ? AppColors.dark : AppColors.textSecondary,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
              fontSize: Responsive.fontSizeXSmall(context),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.paddingMedium(context);
    final spacing = Responsive.spacingMedium(context);
    final isSmallScreen = Responsive.isMobile(context);
    final isDisabledNext =
        hasNextPage == false ||
        (totalPages != null && currentPage >= totalPages!);
    final visibleItems = _getVisibleItems();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prev button
            SizedBox(
              height: Responsive.minTouchTarget,
              child: ElevatedButton.icon(
                onPressed: onPrevPage,
                icon: const Icon(Icons.chevron_left),
                label: Text(isSmallScreen ? 'Prev' : 'Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.darkSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 0.7,
                    vertical: Responsive.paddingSmall(context),
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),

            // Page numbers
            ...visibleItems.asMap().entries.map((entry) {
              final item = entry.value;
              final isLastItem = entry.key == visibleItems.length - 1;
              final child = item is int
                  ? _buildPageButton(context, item, () {
                      if (item == currentPage) return;
                      onPageSelected?.call(item);
                    })
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing * 0.3),
                      child: Text(
                        item.toString(),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.fontSizeSmall(context),
                        ),
                      ),
                    );

              return Row(
                children: [
                  child,
                  if (!isLastItem) SizedBox(width: spacing * 0.5),
                ],
              );
            }),

            SizedBox(width: spacing),

            // Next button
            SizedBox(
              height: Responsive.minTouchTarget,
              child: ElevatedButton.icon(
                onPressed: isDisabledNext ? null : onNextPage,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.darkSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 0.7,
                    vertical: Responsive.paddingSmall(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
