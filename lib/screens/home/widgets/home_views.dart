import 'package:flutter/material.dart';
import '../../../models/anime_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';
import 'anime_card.dart';
import 'pagination_controls.dart';
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        if (isLoading && animeList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (animeList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Text(
              'No data',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          buildAnimeGrid(context: context, animeList: animeList),
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
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
