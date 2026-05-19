import 'package:flutter/material.dart';
import '../../../models/anime_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

class AnimeGridCard extends StatelessWidget {
  final AnimeModel anime;
  final VoidCallback onTap;

  const AnimeGridCard({super.key, required this.anime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster image - takes up most space
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  anime.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.darkSurface,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.darkSurface,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.warning,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Content section - title and rating
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(Responsive.paddingSmall(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title - compact and bounded
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          anime.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.fontSizeSmall(context),
                          ),
                        ),
                      ),
                    ),
                    // Rating - always visible at bottom
                    if (anime.score != null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: Responsive.spacingXSmall(context),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: Responsive.iconSizeSmall(context),
                            ),
                            SizedBox(width: Responsive.spacingXSmall(context)),
                            Text(
                              anime.score!.toStringAsFixed(1),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: Responsive.fontSizeXSmall(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
