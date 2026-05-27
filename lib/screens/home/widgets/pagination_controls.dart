import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

class PaginationControls extends StatefulWidget {
  final int currentPage;
  final VoidCallback? onPrevPage;
  final VoidCallback onNextPage;
  final int? totalPages;
  final bool? hasNextPage;
  final Function(int)? onPageSelected;

  /// Creates pagination controls with modern minimalist numbered page buttons.
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

  @override
  State<PaginationControls> createState() => _PaginationControlsState();
}

class _PaginationControlsState extends State<PaginationControls> {
  int? _pressedPage;

  List<Object> _getVisibleItems() {
    final lastPage = widget.totalPages ?? widget.currentPage;
    if (lastPage <= 0) return const [1];

    int startPage = widget.currentPage - 2;
    int endPage = widget.currentPage + 2;

    if (widget.currentPage >= lastPage - 2) {
      endPage = lastPage;
      startPage = lastPage - 4;
    } else if (widget.currentPage <= 3) {
      startPage = 1;
    }

    startPage = startPage < 1 ? 1 : startPage;
    endPage = endPage > lastPage ? lastPage : endPage;

    final items = <Object>[
      ...List.generate(endPage - startPage + 1, (index) => startPage + index),
    ];

    if (endPage < lastPage) {
      if (endPage < lastPage - 1) {
        items.add('...');
      }
      items.add(lastPage);
    }

    return items;
  }

  Widget _buildPageButton(BuildContext context, int page, VoidCallback onTap) {
    final isCurrentPage = page == widget.currentPage;
    final isSmallScreen = Responsive.isMobile(context);
    final buttonSize = isSmallScreen ? 36.0 : 44.0;
    final isPressed = _pressedPage == page;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedPage = page),
      onTapUp: (_) => setState(() => _pressedPage = null),
      onTapCancel: () => setState(() => _pressedPage = null),
      onTap: onTap,
      child: AnimatedScale(
        scale: isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: isCurrentPage ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(isCurrentPage ? 12 : 8),
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                color: isCurrentPage
                    ? AppColors.dark
                    : AppColors.textSecondary.withValues(alpha: 0.6),
                fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w500,
                fontSize: Responsive.fontSizeXSmall(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isSmallScreen = Responsive.isMobile(context);
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSmallScreen ? 40.0 : 48.0,
        height: isSmallScreen ? 40.0 : 48.0,
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.darkSurface.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isDisabled
                ? AppColors.textSecondary.withValues(alpha: 0.3)
                : AppColors.primary,
            size: isSmallScreen ? 20.0 : 24.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.paddingMedium(context);
    final spacing = Responsive.spacingSmall(context);
    final isDisabledNext =
        widget.hasNextPage == false ||
        (widget.totalPages != null && widget.currentPage >= widget.totalPages!);
    final isDisabledPrev = widget.onPrevPage == null;
    final visibleItems = _getVisibleItems();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildArrowButton(
                    context,
                    icon: Icons.chevron_left,
                    onPressed: isDisabledPrev ? null : widget.onPrevPage,
                  ),
                  SizedBox(width: spacing),
                  ...visibleItems.asMap().entries.map((entry) {
                    final item = entry.value;
                    final isLastItem = entry.key == visibleItems.length - 1;
                    final child = item is int
                        ? _buildPageButton(context, item, () {
                            if (item == widget.currentPage) return;
                            widget.onPageSelected?.call(item);
                          })
                        : Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing * 0.25,
                            ),
                            child: Text(
                              item.toString(),
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: Responsive.fontSizeSmall(context),
                                fontWeight: FontWeight.w500,
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
                  _buildArrowButton(
                    context,
                    icon: Icons.chevron_right,
                    onPressed: isDisabledNext ? null : widget.onNextPage,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
