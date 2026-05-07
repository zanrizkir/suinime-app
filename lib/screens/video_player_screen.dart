import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/consumet_service.dart';
import '../config/theme/app_theme.dart';
import '../widgets/custom_button.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String animeTitle;
  final int episodeNumber;

  const VideoPlayerScreen({
    super.key,
    required this.animeTitle,
    required this.episodeNumber,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late ConsumetService _consumetService;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _consumetService = ConsumetService();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final result = await _consumetService.getStreamingLinkByTitleAndEpisode(
        widget.animeTitle,
        widget.episodeNumber,
      );

      if (result['success'] && result['videoSources'] != null) {
        final videoSources =
            result['videoSources'] as List<Map<String, dynamic>>;

        if (videoSources.isNotEmpty) {
          final bestQualitySource = videoSources.first;
          final videoUrl = bestQualitySource['url'] as String;

          final controller = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
          );

          try {
            await controller.initialize();

            if (!mounted) {
              await controller.dispose();
              return;
            }

            _chewieController = ChewieController(
              videoPlayerController: controller,
              autoPlay: true,
              looping: false,
              aspectRatio: 16 / 9,
              fullScreenByDefault: false,
              allowFullScreen: true,
              allowMuting: true,
              allowPlaybackSpeedChanging: true,
              showControls: true,
              showControlsOnInitialize: true,
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gagal memuat video',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        errorMessage,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            );

            _videoPlayerController = controller;

            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          } catch (e) {
            await controller.dispose();
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = 'Gagal menginisialisasi video player: $e';
              });
            }
          }
        } else {
          throw Exception('Tidak ada sumber video yang tersedia');
        }
      } else {
        throw Exception(
            result['error'] ?? 'Gagal mendapatkan link streaming');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.animeTitle,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Episode ${widget.episodeNumber}',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      backgroundColor: AppColors.dark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat video...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Video',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Coba Lagi',
                icon: Icons.refresh,
                onPressed: _initializeVideo,
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null && _videoPlayerController != null) {
      return Chewie(controller: _chewieController!);
    }

    return const Center(
      child: Text(
        'Tidak dapat memuat player',
        style: TextStyle(color: AppColors.white),
      ),
    );
  }

  Future<void> retry() async {
    await _initializeVideo();
  }
}