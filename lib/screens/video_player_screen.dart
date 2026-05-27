import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/theme/app_theme.dart';
import '../services/otakudesu_service.dart';
import '../services/video_tracking_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final int malId;
  final String episodeSlug;
  final String animeTitle;
  final String imageUrl;
  final int episodeNumber;
  final List<Map<String, dynamic>> availableEpisodes;

  const VideoPlayerScreen({
    super.key,
    required this.malId,
    required this.episodeSlug,
    required this.animeTitle,
    required this.imageUrl,
    required this.episodeNumber,
    this.availableEpisodes = const [],
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final OtakudesuService _apiService = OtakudesuService();
  WebViewController? _webViewController;

  late String _episodeSlug;
  late int _episodeNumber;
  late final List<_EpisodeChoice> _episodeChoices;

  bool _isLoading = true;
  bool _isNavigatingEpisode = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _episodeTitle = '';
  String? selectedUrl;
  List<_StreamingMirror> _streamingMirrors = const [];
  String? _previousEpisodeSlug;
  String? _nextEpisodeSlug;
  bool _hasPreviousEpisode = false;
  bool _hasNextEpisode = false;

  int get _currentEpisodeIndex {
    return _episodeChoices.indexWhere(
      (episode) => episode.number == _episodeNumber,
    );
  }

  _EpisodeChoice? get _previousEpisode {
    final index = _currentEpisodeIndex;
    if (index > 0) {
      final episode = _episodeChoices[index - 1];
      return episode.number == _episodeNumber - 1 &&
              _previousEpisodeSlug != null
          ? episode.copyWith(slug: _previousEpisodeSlug)
          : episode;
    }

    if (_hasPreviousEpisode && _episodeNumber > 1) {
      return _EpisodeChoice(
        number: _episodeNumber - 1,
        slug: _previousEpisodeSlug,
      );
    }

    return null;
  }

  _EpisodeChoice? get _nextEpisode {
    final index = _currentEpisodeIndex;
    if (index != -1 && index < _episodeChoices.length - 1) {
      final episode = _episodeChoices[index + 1];
      return episode.number == _episodeNumber + 1 && _nextEpisodeSlug != null
          ? episode.copyWith(slug: _nextEpisodeSlug)
          : episode;
    }

    if (_hasNextEpisode) {
      return _EpisodeChoice(number: _episodeNumber + 1, slug: _nextEpisodeSlug);
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _episodeSlug = widget.episodeSlug;
    _episodeNumber = widget.episodeNumber;
    _episodeChoices = _normalizeEpisodes(widget.availableEpisodes);
    _loadEpisodeData();
  }

  Future<void> _loadEpisodeData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      selectedUrl = null;
      _streamingMirrors = const [];
    });

    final result = await _apiService.fetchEpisodeStream(_episodeSlug);

    if (result['success'] == true) {
      final streamUrl = result['streamUrl']?.toString();
      final mirrors = _normalizeStreamingMirrors(
        result['mirrors'],
        fallbackUrl: streamUrl,
      );
      final nextSelectedUrl = mirrors.isNotEmpty
          ? mirrors.first.url
          : streamUrl;

      if (nextSelectedUrl == null || nextSelectedUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Link streaming tidak tersedia';
          });
        }
        return;
      }

      await VideoTrackingService.recordEpisodeWatch(
        malId: widget.malId,
        animeTitle: widget.animeTitle,
        imageUrl: widget.imageUrl,
        episodeNumber: _episodeNumber,
      );

      if (mounted) {
        setState(() {
          _episodeTitle = result['title']?.toString() ?? widget.animeTitle;
          _hasPreviousEpisode = result['hasPrev'] == true;
          _previousEpisodeSlug = result['prevSlug']?.toString();
          _hasNextEpisode = result['hasNext'] == true;
          _nextEpisodeSlug = result['nextSlug']?.toString();
          _streamingMirrors = mirrors;
          selectedUrl = nextSelectedUrl;
          _initializeWebView(nextSelectedUrl);
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

  List<_StreamingMirror> _normalizeStreamingMirrors(
    dynamic mirrors, {
    String? fallbackUrl,
  }) {
    final normalized = <_StreamingMirror>[];
    final seen = <String>{};

    void addMirror(String? label, String? url) {
      final cleanUrl = url?.trim();
      if (cleanUrl == null || cleanUrl.isEmpty || !seen.add(cleanUrl)) return;

      final cleanLabel = label?.trim();
      normalized.add(
        _StreamingMirror(
          label: cleanLabel == null || cleanLabel.isEmpty
              ? 'Server ${normalized.length + 1}'
              : cleanLabel,
          url: cleanUrl,
        ),
      );
    }

    if (mirrors is List) {
      for (final mirror in mirrors) {
        if (mirror is Map) {
          final label = _firstText([
            mirror['label'],
            mirror['quality'],
            mirror['resolution'],
            mirror['server'],
            mirror['name'],
          ]);
          final url = _firstText([
            mirror['url'],
            mirror['stream_url'],
            mirror['streaming_url'],
            mirror['embed_url'],
            mirror['link'],
          ]);
          addMirror(label, url);
        } else {
          addMirror(null, mirror?.toString());
        }
      }
    }

    addMirror('Default', fallbackUrl);
    return normalized;
  }

  String? _firstText(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  void _selectStreamingMirror(_StreamingMirror mirror) {
    if (selectedUrl == mirror.url) return;

    setState(() {
      selectedUrl = mirror.url;
    });
    _webViewController?.loadRequest(Uri.parse(mirror.url));
  }

  List<_EpisodeChoice> _normalizeEpisodes(List<Map<String, dynamic>> episodes) {
    final seen = <int>{};
    final normalized = <_EpisodeChoice>[];

    for (var index = 0; index < episodes.length; index++) {
      final episode = episodes[index];
      final number =
          _parseEpisodeNumber(episode['number']) ??
          _parseEpisodeNumber(episode['episodeNumber']) ??
          index + 1;

      if (number <= 0 || !seen.add(number)) continue;

      normalized.add(
        _EpisodeChoice(number: number, title: episode['title']?.toString()),
      );
    }

    normalized.sort((a, b) => a.number.compareTo(b.number));
    return normalized;
  }

  int? _parseEpisodeNumber(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> _openEpisode(_EpisodeChoice episode) async {
    if (_isNavigatingEpisode || episode.number == _episodeNumber) return;

    setState(() {
      _isNavigatingEpisode = true;
    });

    try {
      final slug =
          episode.slug ??
          await _apiService.findEpisodeSlugExact(
            widget.animeTitle,
            episode.number,
          );

      if (!mounted) return;

      if (slug == null || slug.isEmpty) {
        setState(() {
          _isNavigatingEpisode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Episode ini belum tersedia di server video.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() {
        _episodeSlug = slug;
        _episodeNumber = episode.number;
        _episodeTitle = '';
        _previousEpisodeSlug = null;
        _nextEpisodeSlug = null;
        _hasPreviousEpisode = false;
        _hasNextEpisode = false;
        _webViewController = null;
        _isNavigatingEpisode = false;
      });

      await _loadEpisodeData();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isNavigatingEpisode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka episode: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showEpisodeList() {
    final episodes = List<_EpisodeChoice>.from(_episodeChoices);
    if (!episodes.any((episode) => episode.number == _episodeNumber)) {
      episodes.add(
        _EpisodeChoice(
          number: _episodeNumber,
          title: _episodeTitle.isEmpty ? null : _episodeTitle,
          slug: _episodeSlug,
        ),
      );
      episodes.sort((a, b) => a.number.compareTo(b.number));
    }

    if (episodes.isEmpty) {
      episodes.add(
        _EpisodeChoice(
          number: _episodeNumber,
          title: _episodeTitle.isEmpty ? null : _episodeTitle,
          slug: _episodeSlug,
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.68,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'All Episode',
                          style: AppTextStyles.heading4,
                        ),
                      ),
                      Text(
                        '${episodes.length} eps',
                        style: AppTextStyles.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 82,
                            mainAxisExtent: 54,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: episodes.length,
                      itemBuilder: (context, index) {
                        final episode = episodes[index];
                        final isCurrent = episode.number == _episodeNumber;

                        return _EpisodeTile(
                          episode: episode,
                          isCurrent: isCurrent,
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _openEpisode(episode);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(
          _episodeTitle.isEmpty
              ? '${widget.animeTitle} - Episode $_episodeNumber'
              : _episodeTitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPlayerFrame(),
          if (_isNavigatingEpisode)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primary,
              backgroundColor: AppColors.darkSurface,
            ),
          _buildMirrorSelector(),
          _buildEpisodeControls(),
          Expanded(child: _buildEpisodeInfo()),
        ],
      ),
    );
  }

  Widget _buildPlayerFrame() {
    return Container(
      color: AppColors.dark,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _buildPlayerContent(),
        ),
      ),
    );
  }

  Widget _buildPlayerContent() {
    if (_isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Menyiapkan pemutar video...',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        key: const ValueKey('error'),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 34),
              const SizedBox(height: 8),
              const Text(
                'Gagal Memuat Video',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loadEpisodeData,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_webViewController != null) {
      return WebViewWidget(
        key: ValueKey('webview-$_episodeSlug-$selectedUrl'),
        controller: _webViewController!,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMirrorSelector() {
    if (_streamingMirrors.length <= 1) return const SizedBox.shrink();

    return Container(
      color: AppColors.dark,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < _streamingMirrors.length; index++) ...[
              ChoiceChip(
                label: Text(
                  _streamingMirrors[index].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: selectedUrl == _streamingMirrors[index].url,
                onSelected: _isLoading || _isNavigatingEpisode
                    ? null
                    : (_) => _selectStreamingMirror(_streamingMirrors[index]),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.darkSurface,
                disabledColor: AppColors.darkSurface,
                checkmarkColor: AppColors.white,
                side: BorderSide(
                  color: selectedUrl == _streamingMirrors[index].url
                      ? AppColors.primary
                      : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelStyle: TextStyle(
                  color: selectedUrl == _streamingMirrors[index].url
                      ? AppColors.white
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (index != _streamingMirrors.length - 1)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeControls() {
    final previousEpisode = _previousEpisode;
    final nextEpisode = _nextEpisode;
    final isBusy = _isLoading || _isNavigatingEpisode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStack = constraints.maxWidth < 360;
          final buttonWidth = shouldStack
              ? constraints.maxWidth
              : (constraints.maxWidth - 16) / 3;

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: buttonWidth,
                child: _EpisodeNavButton(
                  icon: Icons.skip_previous_rounded,
                  label: 'Previous',
                  onPressed: !isBusy && previousEpisode != null
                      ? () => _openEpisode(previousEpisode)
                      : null,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child: _EpisodeNavButton(
                  icon: Icons.grid_view_rounded,
                  label: 'All Episode',
                  isPrimary: true,
                  onPressed: _isNavigatingEpisode ? null : _showEpisodeList,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child: _EpisodeNavButton(
                  icon: Icons.skip_next_rounded,
                  label: 'Next',
                  onPressed: !isBusy && nextEpisode != null
                      ? () => _openEpisode(nextEpisode)
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEpisodeInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.animeTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading4,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Episode $_episodeNumber',
                  ),
                  if (_episodeTitle.isNotEmpty)
                    _InfoChip(
                      icon: Icons.local_movies_outlined,
                      label: _episodeTitle,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreamingMirror {
  final String label;
  final String url;

  const _StreamingMirror({required this.label, required this.url});
}

class _EpisodeChoice {
  final int number;
  final String? title;
  final String? slug;

  const _EpisodeChoice({required this.number, this.title, this.slug});

  _EpisodeChoice copyWith({String? slug}) {
    return _EpisodeChoice(
      number: number,
      title: title,
      slug: slug ?? this.slug,
    );
  }
}

class _EpisodeNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _EpisodeNavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isPrimary ? AppColors.white : AppColors.primary;
    final backgroundColor = isPrimary ? AppColors.primary : AppColors.dark;

    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: AppColors.textTertiary,
          side: BorderSide(
            color: onPressed == null
                ? AppColors.border
                : isPrimary
                ? AppColors.primary
                : AppColors.border,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final _EpisodeChoice episode;
  final bool isCurrent;
  final VoidCallback onTap;

  const _EpisodeTile({
    required this.episode,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrent
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.dark,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent ? AppColors.primary : AppColors.border,
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Center(
            child: Text(
              'EP ${episode.number}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCurrent ? AppColors.primary : AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width - 88,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
