import 'package:flutter/material.dart';
import '../../../models/anime_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/skeleton_loaders.dart';
import 'anime_card.dart';
import 'pagination_controls.dart';
import 'ranked_anime_list.dart';
import 'section_header.dart';
import '../../detail_screen.dart';

class HomeViews {
  HomeViews._();

  static Widget buildPreviewSection({
    required BuildContext context,
    required String title,
    required List<AnimeModel> animeList,
    required bool isLoading,
    required VoidCallback onSeeAll,
    bool ranked = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        if (isLoading && animeList.isEmpty)
          const SectionSkeleton(title: '', itemCount: 4)
        else if (animeList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Text(
              'No data',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ranked
              ? RankedAnimeList(
                  animeList: animeList,
                  onAnimeTap: (anime) => openDetail(context, anime),
                )
              : buildAnimeGrid(context: context, animeList: animeList),
      ],
    );
  }

  static Widget buildScrollableGridSection({
    required BuildContext context,
    required List<AnimeModel> animeList,
    required bool isLoading,
    required int currentPage,
    required int totalPages,
    required VoidCallback? onPrevPage,
    required VoidCallback onNextPage,
    required ValueChanged<int> onPageSelected,
    bool? hasNextPage,
  }) {
    if (isLoading && animeList.isEmpty) {
      return const AnimeGridSkeleton(count: 8);
    }
    if (animeList.isEmpty && !isLoading) {
      return const Center(
        child: Text(
          'No data',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          buildAnimeGrid(context: context, animeList: animeList),
          PaginationControls(
            currentPage: currentPage,
            onPrevPage: onPrevPage,
            onNextPage: onNextPage,
            totalPages: totalPages,
            hasNextPage: hasNextPage,
            onPageSelected: onPageSelected,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget buildScrollableRankedSection({
    required BuildContext context,
    required List<AnimeModel> animeList,
    required bool isLoading,
    required int currentPage,
    required int totalPages,
    required int perPage,
    required VoidCallback? onPrevPage,
    required VoidCallback onNextPage,
    required ValueChanged<int> onPageSelected,
    bool? hasNextPage,
  }) {
    if (isLoading && animeList.isEmpty) {
      return const RankedAnimeListSkeleton(count: 6);
    }
    if (animeList.isEmpty && !isLoading) {
      return const Center(
        child: Text(
          'No data',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          RankedAnimeList(
            animeList: animeList,
            rankOffset: (currentPage - 1) * perPage,
            onAnimeTap: (anime) => openDetail(context, anime),
          ),
          PaginationControls(
            currentPage: currentPage,
            onPrevPage: onPrevPage,
            onNextPage: onNextPage,
            totalPages: totalPages,
            hasNextPage: hasNextPage,
            onPageSelected: onPageSelected,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget buildAnimeGrid({
    required BuildContext context,
    required List<AnimeModel> animeList,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.paddingMedium(context),
        vertical: Responsive.spacingMedium(context),
      ),
      gridDelegate: Responsive.gridDelegateSmall(context),
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final anime = animeList[index];
        return AnimeCard(anime: anime, onTap: () => openDetail(context, anime));
      },
    );
  }

  static void openDetail(BuildContext context, AnimeModel anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          malId: anime.malId,
          animeInfo: {
            'title': anime.title,
            'imageUrl': anime.imageUrl,
            'score': anime.score,
          },
        ),
      ),
    );
  }
}
