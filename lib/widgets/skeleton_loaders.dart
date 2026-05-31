import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme/app_theme.dart';
import '../utils/responsive.dart';

/// Base shimmer wrapper for all skeleton loaders
class ShimmerLoader extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ShimmerLoader({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.darkSurface,
      highlightColor: AppColors.darkSurface.withValues(alpha: 0.6),
      period: duration,
      child: child,
    );
  }
}

/// Skeleton for anime grid card
class AnimeCardSkeleton extends StatelessWidget {
  const AnimeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = Responsive.paddingSmall(context);
        final titleHeight = Responsive.fontSizeSmall(context);
        final infoHeight = Responsive.fontSizeXSmall(context);
        final titleWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth * 0.78
            : double.infinity;
        final infoWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth * 0.42
            : 48.0;

        return ShimmerLoader(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.darkSurface),
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
                Positioned(
                  left: padding,
                  right: padding,
                  bottom: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.92,
                        child: Container(
                          height: titleHeight,
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.spacingSmall(context)),
                      Container(
                        width: titleWidth,
                        height: titleHeight,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: Responsive.spacingXSmall(context)),
                      Container(
                        width: infoWidth,
                        height: infoHeight,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for anime grid - creates multiple cards
class AnimeGridSkeleton extends StatelessWidget {
  final int count;

  const AnimeGridSkeleton({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: Responsive.animeGridPadding(context),
          gridDelegate: Responsive.gridDelegateSmall(context),
          itemCount: count,
          itemBuilder: (context, index) {
            return const AspectRatio(
              aspectRatio: 0.6,
              child: AnimeCardSkeleton(),
            );
          },
        );
      },
    );
  }
}

/// Skeleton for ranked anime list item
class RankedAnimeSkeletonItem extends StatelessWidget {
  const RankedAnimeSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // Image placeholder
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // Info placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for ranked anime list - creates multiple items
class RankedAnimeListSkeleton extends StatelessWidget {
  final int count;

  const RankedAnimeListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const RankedAnimeSkeletonItem(),
    );
  }
}

/// Skeleton for episode list item
class EpisodeSkeletonItem extends StatelessWidget {
  const EpisodeSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Row(
        children: [
          // Thumbnail placeholder
          Container(
            width: 100,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // Info placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for episode list
class EpisodeListSkeleton extends StatelessWidget {
  final int count;

  const EpisodeListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const EpisodeSkeletonItem(),
    );
  }
}

/// Skeleton for detail page header
class DetailHeaderSkeleton extends StatelessWidget {
  const DetailHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster placeholder
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          // Title placeholder
          Container(
            width: double.infinity,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle placeholders
          Row(
            children: [
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for generic list item
class ListItemSkeleton extends StatelessWidget {
  final double height;

  const ListItemSkeleton({super.key, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Skeleton for generic list
class GenericListSkeleton extends StatelessWidget {
  final int count;
  final double itemHeight;
  final double spacing;

  const GenericListSkeleton({
    super.key,
    this.count = 6,
    this.itemHeight = 60,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: count,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => ListItemSkeleton(height: itemHeight),
    );
  }
}

/// Skeleton for section with title and grid
class SectionSkeleton extends StatelessWidget {
  final String title;
  final int itemCount;

  const SectionSkeleton({super.key, required this.title, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.paddingMedium(context),
              vertical: Responsive.spacingMedium(context),
            ),
            child: ShimmerLoader(
              child: Container(
                width: 150,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        AnimeGridSkeleton(count: itemCount),
      ],
    );
  }
}

/// Skeleton for search results
class SearchResultSkeleton extends StatelessWidget {
  final int count;

  const SearchResultSkeleton({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) {
    return AnimeGridSkeleton(count: count);
  }
}

/// Skeleton for horizontal carousel/scroll
class HorizontalScrollSkeleton extends StatelessWidget {
  final int count;
  final double itemWidth;
  final double itemHeight;

  const HorizontalScrollSkeleton({
    super.key,
    this.count = 5,
    this.itemWidth = 150,
    this.itemHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(
          count,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ShimmerLoader(
              child: Container(
                width: itemWidth,
                height: itemHeight,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton for genre list with letter grouping
class GenreListSkeleton extends StatelessWidget {
  final int groupCount;
  final int itemsPerGroup;

  const GenreListSkeleton({
    super.key,
    this.groupCount = 5,
    this.itemsPerGroup = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: groupCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: ShimmerLoader(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Container(width: 2, color: AppColors.darkSurface),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          itemsPerGroup,
                          (i) => Container(
                            width: 80,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
