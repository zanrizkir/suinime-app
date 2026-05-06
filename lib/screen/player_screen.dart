import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../config/theme/app_theme.dart';

// Constants
const double _horizontalPadding = 16.0;
const double _videoAspectRatio = 16 / 9;
const double _borderRadius = 12.0;
const Duration _controlsAutoHideDuration = Duration(seconds: 5);

// Colors
const Color _darkBackground = AppColors.darkBg;
const Color _darkSurface = AppColors.darkSurface;
const Color _accentColor = AppColors.accentOrange;
const Color _textSecondary = AppColors.textSecondary;

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

// Dummy episodes list
final List<EpisodeData> dummyEpisodes = [
  EpisodeData(episodeNumber: 1, title: 'Ryomen Sukuna', duration: '23m'),
  EpisodeData(episodeNumber: 2, title: 'Jujutsu High', duration: '24m'),
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
  EpisodeData(episodeNumber: 5, title: 'Creeping Darkness', duration: '24m'),
  EpisodeData(episodeNumber: 6, title: 'After Rain', duration: '24m'),
  EpisodeData(episodeNumber: 7, title: 'Assault', duration: '24m'),
  EpisodeData(episodeNumber: 8, title: 'Boredom', duration: '24m'),
];

class PlayerScreen extends StatefulWidget {
  final int currentEpisodeNumber;
  final String animeTitle;

  const PlayerScreen({
    super.key,
    this.currentEpisodeNumber = 1,
    this.animeTitle = 'Jujutsu Kaisen',
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoController;
  bool _isControlsVisible = true;
  late Duration _controlsAutoHideTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _videoController =
        VideoPlayerController.networkUrl(
            Uri.parse(
              'https://commondatastorage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4',
            ),
          )
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
          });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    _startAutoHideTimer();
  }

  void _startAutoHideTimer() {
    if (_isControlsVisible) {
      Future.delayed(_controlsAutoHideDuration, () {
        if (mounted && _videoController.value.isPlaying) {
          setState(() {
            _isControlsVisible = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video player
            _buildVideoPlayer(),
            SizedBox(height: 16),
            // Episode info
            _buildEpisodeInfo(),
            SizedBox(height: 16),
            // Episode selector
            _buildEpisodeSelector(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControlsVisibility,
      child: Container(
        color: Colors.black,
        width: double.infinity,
        child: _videoController.value.isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _videoAspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                  // Controls overlay
                  VideoControlsOverlay(
                    isVisible: _isControlsVisible,
                    isPlaying: _videoController.value.isPlaying,
                    onPlayPauseTap: _togglePlayPause,
                    videoController: _videoController,
                  ),
                ],
              )
            : AspectRatio(
                aspectRatio: _videoAspectRatio,
                child: const Center(
                  child: CircularProgressIndicator(color: _accentColor),
                ),
              ),
      ),
    );
  }

  Widget _buildEpisodeInfo() {
    final currentEpisode = dummyEpisodes.firstWhere(
      (ep) => ep.episodeNumber == widget.currentEpisodeNumber,
      orElse: () => dummyEpisodes.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Episode ${currentEpisode.episodeNumber} - ${currentEpisode.title}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${widget.animeTitle} • Duration: ${currentEpisode.duration}',
            style: const TextStyle(color: _textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More Episodes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dummyEpisodes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: EpisodeSelectorItem(
                    episode: dummyEpisodes[index],
                    isCurrentEpisode:
                        dummyEpisodes[index].episodeNumber ==
                        widget.currentEpisodeNumber,
                    onTap: () {
                      debugPrint(
                        'Tapped Episode ${dummyEpisodes[index].episodeNumber}',
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Video controls overlay with play/pause, progress bar, and fullscreen button
class VideoControlsOverlay extends StatefulWidget {
  final bool isVisible;
  final bool isPlaying;
  final VoidCallback onPlayPauseTap;
  final VideoPlayerController videoController;

  const VideoControlsOverlay({
    super.key,
    required this.isVisible,
    required this.isPlaying,
    required this.onPlayPauseTap,
    required this.videoController,
  });

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Center play/pause button
          GestureDetector(
            onTap: widget.onPlayPauseTap,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Top controls
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
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
                GestureDetector(
                  onTap: () {
                    debugPrint('Fullscreen tapped');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar
                  VideoProgressIndicator(
                    widget.videoController,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: _accentColor,
                      bufferedColor: Colors.grey[700]!,
                      backgroundColor: Colors.grey[900]!,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Time display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(widget.videoController.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(widget.videoController.value.duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

/// Reusable episode selector item for horizontal list
class EpisodeSelectorItem extends StatelessWidget {
  final EpisodeData episode;
  final bool isCurrentEpisode;
  final VoidCallback onTap;

  const EpisodeSelectorItem({
    super.key,
    required this.episode,
    required this.isCurrentEpisode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: isCurrentEpisode
              ? _accentColor.withOpacity(0.3)
              : _darkSurface,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: isCurrentEpisode ? _accentColor : Colors.grey[800]!,
            width: isCurrentEpisode ? 2 : 0.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'EP ${episode.episodeNumber}',
              style: TextStyle(
                color: isCurrentEpisode ? _accentColor : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              episode.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _textSecondary, fontSize: 10),
            ),
            SizedBox(height: 6),
            Text(
              episode.duration,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
