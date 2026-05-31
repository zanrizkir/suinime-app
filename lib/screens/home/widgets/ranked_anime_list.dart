import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';
import '../../../models/anime_model.dart';
import '../../../utils/responsive.dart';

class RankedAnimeList extends StatelessWidget {
  final List<AnimeModel> animeList;
  final int rankOffset;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final void Function(AnimeModel anime) onAnimeTap;

  const RankedAnimeList({
    super.key,
    required this.animeList,
    required this.onAnimeTap,
    this.rankOffset = 0,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    final orderedAnimeList = _orderedByRankWhenAvailable(animeList);

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.paddingMedium(context),
        vertical: Responsive.spacingMedium(context),
      ),
      itemCount: orderedAnimeList.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: Responsive.spacingSmall(context)),
      itemBuilder: (context, index) {
        final anime = orderedAnimeList[index];
        final rank = rankOffset + index + 1;
        return _RankedAnimeTile(
          anime: anime,
          rank: rank,
          onTap: () => onAnimeTap(anime),
        );
      },
    );
  }

  List<AnimeModel> _orderedByRankWhenAvailable(List<AnimeModel> animeList) {
    final rankedItems = animeList.where((anime) => anime.rank != null).length;
    if (rankedItems < 2) return animeList;

    final ordered = List<AnimeModel>.of(animeList);
    ordered.sort((a, b) {
      final rankA = a.rank;
      final rankB = b.rank;
      if (rankA == null && rankB == null) return 0;
      if (rankA == null) return 1;
      if (rankB == null) return -1;
      return rankA.compareTo(rankB);
    });
    return ordered;
  }
}

class _RankedAnimeTile extends StatelessWidget {
  final AnimeModel anime;
  final int rank;
  final VoidCallback onTap;

  const _RankedAnimeTile({
    required this.anime,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final posterWidth = isMobile ? 58.0 : 72.0;
    final posterHeight = isMobile ? 82.0 : 100.0;
    final rankText = '#$rank';
    final rankWidth = _rankWidth(context, rankText.length);
    final rankFontSize = _rankFontSize(isMobile, rankText.length);

    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: rankWidth,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    rankText,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: rankFontSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  anime.imageUrl,
                  width: posterWidth,
                  height: posterHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: posterWidth,
                    height: posterHeight,
                    color: AppColors.darkBg,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _MetadataLine(anime: anime),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (anime.score != null)
                          _InfoChip(
                            icon: Icons.star_rounded,
                            label: anime.score!.toStringAsFixed(2),
                            color: AppColors.warning,
                          ),
                        if (anime.members != null)
                          _InfoChip(
                            icon: Icons.people_alt_rounded,
                            label: _formatMembers(anime.members!),
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _rankWidth(BuildContext context, int textLength) {
    final isMobile = Responsive.isMobile(context);
    final baseWidth = isMobile ? 42.0 : 54.0;
    final extraWidth = (textLength - 3).clamp(0, 8) * (isMobile ? 7.0 : 9.0);
    final maxWidth =
        MediaQuery.sizeOf(context).width * (isMobile ? 0.24 : 0.18);
    return (baseWidth + extraWidth).clamp(baseWidth, maxWidth);
  }

  double _rankFontSize(bool isMobile, int textLength) {
    if (textLength <= 3) return isMobile ? 18 : 22;
    if (textLength == 4) return isMobile ? 16 : 20;
    if (textLength <= 6) return isMobile ? 14 : 18;
    return isMobile ? 12 : 16;
  }

  String _formatMembers(int members) {
    if (members >= 1000000) {
      return '${(members / 1000000).toStringAsFixed(1)}M';
    }
    if (members >= 1000) {
      return '${(members / 1000).toStringAsFixed(1)}K';
    }
    return members.toString();
  }
}

class _MetadataLine extends StatelessWidget {
  final AnimeModel anime;

  const _MetadataLine({required this.anime});

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (anime.type != null && anime.type!.isNotEmpty) anime.type!,
      if (anime.episodes != null) '${anime.episodes} eps',
      if (anime.year != null) anime.year.toString(),
    ];

    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      parts.join(' / '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: Responsive.fontSizeXSmall(context),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: Responsive.fontSizeXSmall(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
