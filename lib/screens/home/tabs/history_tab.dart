import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../config/theme/app_theme.dart';
import '../../../models/hive/watch_history_hive.dart';
import '../../../services/hive_service.dart';
import '../../../utils/responsive.dart';
import '../../detail_screen.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<WatchHistoryHive>>(
      valueListenable: Hive.box<WatchHistoryHive>(
        HiveService.watchHistoryBox,
      ).listenable(),
      builder: (context, box, _) {
        final history = HiveService.getWatchHistory(limit: 100);

        if (history.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            12,
            8,
            12,
            Responsive.safeBottomSpacing(context, minimum: 20),
          ),
          itemCount: history.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _HistoryItemCard(item: history[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              color: AppColors.textTertiary,
              size: 52,
            ),
            SizedBox(height: 14),
            Text('Belum ada riwayat tontonan', style: AppTextStyles.heading4),
            SizedBox(height: 6),
            Text(
              'Episode yang kamu putar akan muncul di sini.',
              style: AppTextStyles.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final WatchHistoryHive item;

  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _buildPoster(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _InfoPill(
                          icon: Icons.play_circle_outline_rounded,
                          label: item.lastEpisode > 0
                              ? 'Episode ${item.lastEpisode}'
                              : 'Episode terakhir',
                        ),
                        _InfoPill(
                          icon: Icons.schedule_rounded,
                          label: _formatWatchedAt(item.watchedAt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 88,
        child: item.imageUrl.isEmpty
            ? _posterFallback()
            : Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _posterFallback(),
              ),
      ),
    );
  }

  Widget _posterFallback() {
    return Container(
      color: AppColors.divider,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.textTertiary,
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          malId: item.malId,
          animeInfo: {'title': item.title, 'imageUrl': item.imageUrl},
        ),
      ),
    );
  }

  String _formatWatchedAt(DateTime watchedAt) {
    final now = DateTime.now();
    final difference = now.difference(watchedAt);

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    if (difference.inDays == 1) return 'Kemarin ${_formatClock(watchedAt)}';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';

    return '${_twoDigits(watchedAt.day)}/${_twoDigits(watchedAt.month)}/${watchedAt.year} ${_formatClock(watchedAt)}';
  }

  String _formatClock(DateTime dateTime) {
    return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
