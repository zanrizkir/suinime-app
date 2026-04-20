import 'package:flutter/material.dart';

// Constants
const double _horizontalPadding = 16.0;
const double _verticalPadding = 8.0;
const double _borderRadius = 12.0;
const double _cardAspectRatio = 2 / 3;
const double _cardHeight = 220.0;

// Colors
const Color _darkBackground = Color(0xFF0F0F0F);
const Color _darkSurface = Color(0xFF1A1A1A);
const Color _accentColor = Color(0xFFFF6B6B);

// Dummy data model
class AnimeData {
  final String title;
  final String imageUrl;

  AnimeData({
    required this.title,
    required this.imageUrl,
  });
}

// Dummy anime lists
final List<AnimeData> trendingAnime = [
  AnimeData(
    title: 'Jujutsu Kaisen',
    imageUrl: 'https://via.placeholder.com/300x450?text=Jujutsu+Kaisen',
  ),
  AnimeData(
    title: 'Attack on Titan',
    imageUrl: 'https://via.placeholder.com/300x450?text=Attack+on+Titan',
  ),
  AnimeData(
    title: 'Demon Slayer',
    imageUrl: 'https://via.placeholder.com/300x450?text=Demon+Slayer',
  ),
  AnimeData(
    title: 'Chainsaw Man',
    imageUrl: 'https://via.placeholder.com/300x450?text=Chainsaw+Man',
  ),
  AnimeData(
    title: 'My Hero Academia',
    imageUrl: 'https://via.placeholder.com/300x450?text=MHA',
  ),
];

final List<AnimeData> latestAnime = [
  AnimeData(
    title: 'Wind Breaker',
    imageUrl: 'https://via.placeholder.com/300x450?text=Wind+Breaker',
  ),
  AnimeData(
    title: 'Solo Leveling',
    imageUrl: 'https://via.placeholder.com/300x450?text=Solo+Leveling',
  ),
  AnimeData(
    title: 'Frieren',
    imageUrl: 'https://via.placeholder.com/300x450?text=Frieren',
  ),
  AnimeData(
    title: 'Blue Exorcist',
    imageUrl: 'https://via.placeholder.com/300x450?text=Blue+Exorcist',
  ),
  AnimeData(
    title: 'Haikyu!!',
    imageUrl: 'https://via.placeholder.com/300x450?text=Haikyu',
  ),
];

final List<AnimeData> recommendedAnime = [
  AnimeData(
    title: 'Death Note',
    imageUrl: 'https://via.placeholder.com/300x450?text=Death+Note',
  ),
  AnimeData(
    title: 'Steins;Gate',
    imageUrl: 'https://via.placeholder.com/300x450?text=Steins+Gate',
  ),
  AnimeData(
    title: 'Code Geass',
    imageUrl: 'https://via.placeholder.com/300x450?text=Code+Geass',
  ),
  AnimeData(
    title: 'Cowboy Bebop',
    imageUrl: 'https://via.placeholder.com/300x450?text=Cowboy+Bebop',
  ),
  AnimeData(
    title: 'Neon Genesis',
    imageUrl: 'https://via.placeholder.com/300x450?text=Evangelion',
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: _verticalPadding),
            const _FeaturedBanner(),
            SizedBox(height: 24),
            AnimeSection(
              title: 'Trending Now',
              animeList: trendingAnime,
            ),
            SizedBox(height: 24),
            AnimeSection(
              title: 'Latest Update',
              animeList: latestAnime,
            ),
            SizedBox(height: 24),
            AnimeSection(
              title: 'Recommended',
              animeList: recommendedAnime,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _darkSurface,
      elevation: 0,
      title: const Text(
        'Suinime',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}

/// Featured banner section with gradient overlay and featured anime
class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _accentColor.withOpacity(0.8),
                _accentColor.withOpacity(0.4),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.network(
                  'https://via.placeholder.com/600x200?text=Featured+Anime',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _accentColor.withOpacity(0.6),
                            Colors.purple.withOpacity(0.4),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              // Text content
              const Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Jujutsu Kaisen Season 2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
}

/// Reusable section widget for displaying anime lists
class AnimeSection extends StatelessWidget {
  final String title;
  final List<AnimeData> animeList;

  const AnimeSection({
    Key? key,
    required this.title,
    required this.animeList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        // Horizontal scrollable list
        SizedBox(
          height: _cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimeCard(anime: animeList[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual anime card with image and title
class AnimeCard extends StatelessWidget {
  final AnimeData anime;

  const AnimeCard({
    Key? key,
    required this.anime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Poster image with rounded corners
        ClipRRect(
          borderRadius: BorderRadius.circular(_borderRadius),
          child: Container(
            width: _cardHeight * _cardAspectRatio,
            height: _cardHeight,
            decoration: BoxDecoration(
              color: _darkSurface,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Network image
                Image.network(
                  anime.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[800]!,
                            Colors.grey[900]!,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
                // Gradient overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        // Anime title (max 2 lines with ellipsis)
        SizedBox(
          width: _cardHeight * _cardAspectRatio,
          child: Text(
            anime.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}