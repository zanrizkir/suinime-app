import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const SectionHeader({super.key, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.paddingMedium(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding,
        Responsive.spacingLarge(context),
        padding,
        Responsive.spacingSmall(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: Responsive.fontSizeLarge(context),
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.paddingSmall(context),
                vertical: Responsive.paddingSmall(context),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Lihat Selengkapnya',
              style: TextStyle(
                fontSize: Responsive.fontSizeSmall(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
