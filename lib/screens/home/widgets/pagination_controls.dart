import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

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
    final padding = Responsive.paddingMedium(context);
    final spacing = Responsive.spacingLarge(context);
    final isSmallScreen = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: Responsive.minTouchTarget,
              child: ElevatedButton(
                onPressed: onPrevPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.darkSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: Responsive.paddingSmall(context),
                  ),
                ),
                child: Text(
                  isSmallScreen ? 'Prev' : 'Previous',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: Responsive.fontSizeSmall(context),
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: Responsive.paddingSmall(context),
              ),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Text(
                'Page $currentPage',
                style: TextStyle(
                  fontSize: Responsive.fontSizeSmall(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: spacing),
            SizedBox(
              height: Responsive.minTouchTarget,
              child: ElevatedButton(
                onPressed: onNextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: Responsive.paddingSmall(context),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: Responsive.fontSizeSmall(context),
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
