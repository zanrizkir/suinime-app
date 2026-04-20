import 'package:flutter/material.dart';

// Constants
const double _horizontalPadding = 16.0;
const double _verticalSpacing = 12.0;
const double _borderRadius = 12.0;
const double _bannerHeight = 280.0;

// Colors
const Color _darkBackground = Color(0xFF0F0F0F);
const Color _darkSurface = Color(0xFF1A1A1A);
const Color _accentColor = Color(0xFFFF6B6B);
const Color _textSecondary = Color(0xFFB0B0B0);

// Dummy data models
class EpisodeData {
  final int episodeNumber;
  final String title;
  final String duration;

  EpisodeData({
    required this.episodeNumber,
    required this.title,
    required this.duration,
  });
}

class AnimeDetailData {
  final String title;
  final List<String> genres;
  final double rating;
  final String posterUrl;
  final String synopsis;
  final List<EpisodeData> episodes;

  AnimeDetailData({
    required this.title,
    required this.genres,
    required this.rating,
    required this.posterUrl,
    required this.synopsis,
    required this.episodes,
  });
}

// Dummy anime detail data
final AnimeDetailData animeDetail = AnimeDetailData(
  title: 'Jujutsu Kaisen',
  genres: ['Action', 'Dark Fantasy', 'Supernatural'],
  rating: 8.9,
  posterUrl: 'https://via.placeholder.com/400x600?text=Jujutsu+Kaisen',
  synopsis:
      'Yuji Itadori is a high schooler who figures out that the two things he loves the most after spending the last 2 years of his life with them as friends, were pleasure and jujutsu. Leadingly, Yuji is then coerced into swallowing a demon\'s finger, which also turns out to be a member of a secret organization of demons who protect the world from supernatural forces.',
  episodes: [
    EpisodeData(
      episodeNumber: 1,
      title: 'Ryomen Sukuna',
      duration: '23m',
    ),
    EpisodeData(
      episodeNumber: 2,
      title: 'Jujutsu High',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 3,
      title: 'Girl of the Occult Club',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 4,
      title: 'Curse Womb Arc Begins',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 5,
      title: 'Creeping Darkness',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 6,
      title: 'After Rain',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 7,
      title: 'Assault',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 8,
      title: 'Boredom',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 9,
      title: 'Premature Death',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 10,
      title: 'Cursed Wombs & Demons',
      duration: '24m',
    ),
    EpisodeData(
      episodeNumber: 11,
      title: 'Narrow Escape',
      duration: '25m',
    ),
    EpisodeData(
      episodeNumber: 12,
      title: 'Shibuya Incident - Annoucement',
      duration: '25m',
    ),
  ],
);

class DetailScreen extends StatelessWidget {
  final AnimeDetailData anime;

  DetailScreen({
    Key? key,
    AnimeDetailData? data,
  })  : anime = data ?? animeDetail,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top banner with poster and overlay
            _BannerSection(anime: anime),
            SizedBox(height: _verticalSpacing * 2),
            // Anime info section
            _AnimeInfoSection(anime: anime),
            SizedBox(height: _verticalSpacing * 2),
            // Synopsis section
            _SynopsisSection(synopsis: anime.synopsis),
            SizedBox(height: _verticalSpacing * 2),
            // Episodes section
            _EpisodesSection(episodes: anime.episodes),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Top banner section with poster image and gradient overlay
class _BannerSection extends StatelessWidget {
  final AnimeDetailData anime;

  const _BannerSection({
    Key? key,
    required this.anime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Container(
          height: _bannerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _darkSurface,
          ),
          child: Image.network(
            anime.posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
        // Gradient overlay
        Container(
          height: _bannerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                _darkBackground.withOpacity(0.95),
              ],
            ),
          ),
        ),
        // Back button (top-left)
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        // Favorite button (top-right)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bookmark_border,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

/// Anime information section (title, genres, rating)
class _AnimeInfoSection extends StatelessWidget {
  final AnimeDetailData anime;

  const _AnimeInfoSection({
    Key? key,
    required this.anime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            anime.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: _verticalSpacing),
          // Genres
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: anime.genres
                .map(
                  (genre) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _darkSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _accentColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: _verticalSpacing),
          // Rating
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFFFD700),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                anime.rating.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              const Text(
                '/10',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Synopsis section
class _SynopsisSection extends StatelessWidget {
  final String synopsis;

  const _SynopsisSection({
    Key? key,
    required this.synopsis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Synopsis'),
          SizedBox(height: _verticalSpacing),
          Text(
            synopsis,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Episodes section with list of episodes
class _EpisodesSection extends StatelessWidget {
  final List<EpisodeData> episodes;

  const _EpisodesSection({
    Key? key,
    required this.episodes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Episodes (${episodes.length})'),
          SizedBox(height: _verticalSpacing),
          Column(
            children: List.generate(
              episodes.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < episodes.length - 1 ? 10 : 0,
                ),
                child: EpisodeItem(episode: episodes[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable section title widget
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Reusable episode item widget
class EpisodeItem extends StatelessWidget {
  final EpisodeData episode;

  const EpisodeItem({
    Key? key,
    required this.episode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('Tapped Episode ${episode.episodeNumber}');
        },
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _darkSurface,
            borderRadius: BorderRadius.circular(_borderRadius),
            border: Border.all(
              color: Colors.grey[800]!,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Episode number indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _accentColor.withOpacity(0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    'EP\n${episode.episodeNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Episode info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Episode ${episode.episodeNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      episode.title,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // Duration
              Text(
                episode.duration,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 8),
              // Play icon
              const Icon(
                Icons.play_arrow,
                color: _accentColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
