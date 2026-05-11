import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/otakudesu_service.dart';
import '../config/theme/app_theme.dart';
import '../widgets/custom_button.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String episodeSlug;
  final String animeTitle;

  const VideoPlayerScreen({
    super.key,
    required this.episodeSlug,
    required this.animeTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final OtakudesuService _apiService = OtakudesuService();
  WebViewController? _webViewController;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _episodeTitle = '';

  @override
  void initState() {
    super.initState();
    _loadEpisodeData();
  }

  Future<void> _loadEpisodeData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    final result =
        await _apiService.fetchEpisodeStream(widget.episodeSlug);

    if (result['success'] == true) {
      final streamUrl = result['streamUrl'] as String;

      if (mounted) {
        setState(() {
          _episodeTitle = result['title']?.toString() ?? widget.animeTitle;
          _initializeWebView(streamUrl);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage =
              result['error']?.toString() ?? 'Terjadi kesalahan sistem';
        });
      }
    }
  }

  void _initializeWebView(String url) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.dark)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {},
          onPageFinished: (_) {
            _webViewController?.runJavaScript(
              "document.body.style.margin='0';"
              "document.body.style.padding='0';"
              "document.body.style.backgroundColor='black';",
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(
          _episodeTitle.isEmpty ? widget.animeTitle : _episodeTitle,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Menyiapkan pemutar video...',
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
                onPressed: _loadEpisodeData,
              ),
            ],
          ),
        ),
      );
    }

    if (_webViewController != null) {
      return Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: WebViewWidget(controller: _webViewController!),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Gunakan tombol fullscreen pada pemutar video',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}