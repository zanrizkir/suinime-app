import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class MoreTab extends StatefulWidget {
  final VoidCallback onGenreTap;
  final VoidCallback onCompletedTap;

  const MoreTab({
    super.key,
    required this.onGenreTap,
    required this.onCompletedTap,
  });

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  @override
  Widget build(BuildContext context) {
    return _buildMoreBody();
  }

  //==== LAINNYA =====

  Widget _buildMoreBody() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildMoreMenuTile(
          icon: Icons.category_outlined,
          title: 'Genre List',
          subtitle: 'Jelajahi anime berdasarkan genre',
          onTap: widget.onGenreTap,
        ),
        const SizedBox(height: 10),
        _buildMoreMenuTile(
          icon: Icons.check_circle_outline_rounded,
          title: 'Completed Anime',
          subtitle: 'Daftar anime yang sudah selesai',
          onTap: widget.onCompletedTap,
        ),
      ],
    );
  }

  Widget _buildMoreMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey),
          ],
        ),
      ),
    );
  }
}
