import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/consumet_service.dart';

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
      // Panggil fungsi gabungan dari ConsumetService
      final result = await _consumetService.getStreamingLinkByTitleAndEpisode(
        widget.animeTitle,
        widget.episodeNumber,
      );

      if (result['success'] && result['videoSources'] != null) {
        final videoSources = result['videoSources'] as List<Map<String, dynamic>>;
        
        if (videoSources.isNotEmpty) {
          // Ambil URL kualitas tertinggi (sudah terurut dari service)
          final bestQualitySource = videoSources.first;
          final videoUrl = bestQualitySource['url'] as String;
          
          // Inisialisasi VideoPlayerController
          final controller = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
          );
          
          try {
            // Initialize dengan try-catch untuk mencegah memory leak [citation:2]
            await controller.initialize();
            
            if (!mounted) {
              await controller.dispose();
              return;
            }
            
            // Setup ChewieController
            _chewieController = ChewieController(
              videoPlayerController: controller,
              autoPlay: true,
              looping: false,
              aspectRatio: 16 / 9, // Rasio aspek 16:9 [citation:4]
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
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat video',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
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
            // Init gagal, dispose controller untuk mencegah memory leak [citation:2]
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
        throw Exception(result['error'] ?? 'Gagal mendapatkan link streaming');
      }
    } catch (e) {
      print('Error initializing video: $e');
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
    // Dispose dengan urutan yang benar untuk mencegah memory leak [citation:6]
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Episode ${widget.episodeNumber}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    // State Loading
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat video...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    // State Error
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Video',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeVideo,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // State Success - Menampilkan Video Player
    if (_chewieController != null && _videoPlayerController != null) {
      return Chewie(
        controller: _chewieController!,
      );
    }

    // Fallback
    return const Center(
      child: Text(
        'Tidak dapat memuat player',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Method untuk manual retry (opsional, bisa dipanggil dari luar)
  Future<void> retry() async {
    await _initializeVideo();
  }
}