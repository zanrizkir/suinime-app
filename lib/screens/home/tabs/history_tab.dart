import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class HistoryTab extends StatefulWidget {
  final List<Map<String, dynamic>> watchHistory;

  const HistoryTab({super.key, required this.watchHistory});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  void initState() {
    super.initState();
    _loadWatchHistory();
  }

  Future<void> _loadWatchHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildHistoryBody();
  }

  //==== RIWAYAT =====

  Widget _buildHistoryBody() {
    if (widget.watchHistory.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat tontonan',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.watchHistory.length,
      itemBuilder: (context, index) {
        final item = widget.watchHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item['title']?.toString() ?? 'Untitled',
            style: AppTextStyles.labelLarge,
          ),
        );
      },
    );
  }
}
