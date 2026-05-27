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
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.paddingMedium(context),
        vertical: Responsive.spacingMedium(context),
      ),
      itemCount: animeList.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: Responsive.spacingSmall(context)),
      itemBuilder: (context, index) {
        final anime = animeList[index];
        final rank = anime.rank ?? rankOffset + index + 1;
        return _RankedAnimeTile(
          anime: anime,
          rank: rank,
          onTap: () => onAnimeTap(anime),
        );
      },
    );
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
    final rankWidth = isMobile ? 42.0 : 54.0;

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
                child: Text(
                  '#$rank',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.w800,
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
