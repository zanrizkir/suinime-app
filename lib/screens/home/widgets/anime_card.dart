import 'package:flutter/material.dart';
import '../../../models/anime_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

/// Unified anime card widget for consistent design across all screens.
/// Based on the stable Library tab card design with gradient overlay.
class AnimeCard extends StatelessWidget {
  final AnimeModel anime;
  final VoidCallback onTap;
  final bool enableShadow;

  const AnimeCard({
    super.key,
    required this.anime,
    required this.onTap,
    this.enableShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: enableShadow
              ? [
                  BoxShadow(
                    color: AppColors.dark.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image
              anime.imageUrl.isNotEmpty
                  ? Image.network(
                      anime.imageUrl,
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
                    )
                  : Container(
                      color: AppColors.darkSurface,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.dark.withValues(alpha: 0),
                      AppColors.dark.withValues(alpha: 0.8),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              // Content overlay at bottom
              Positioned(
                bottom: Responsive.paddingSmall(context),
                left: Responsive.paddingSmall(context),
                right: Responsive.paddingSmall(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.fontSizeSmall(context),
                      ),
                    ),
                    // Rating
                    if (anime.score != null) ...[
                      SizedBox(height: Responsive.spacingXSmall(context)),
                      Row(
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
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: Responsive.fontSizeXSmall(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
