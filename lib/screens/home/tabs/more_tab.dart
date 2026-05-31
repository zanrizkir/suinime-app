import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import '../../category_management_screen.dart';
import '../../data_storage_screen.dart';
import '../../genre_list_screen.dart';
import '../../completed_anime_screen.dart';

class MoreTab extends StatefulWidget {
  const MoreTab({super.key});

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildMoreBody();
  }

  Widget _buildMoreBody() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildMoreMenuTile(
          icon: Icons.category_outlined,
          title: 'Genre List',
          subtitle: 'Jelajahi anime berdasarkan genre',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GenreListScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMoreMenuTile(
          icon: Icons.check_circle_outline_rounded,
          title: 'Completed Anime',
          subtitle: 'Daftar anime yang sudah selesai',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompletedAnimeScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMoreMenuTile(
          icon: Icons.folder_outlined,
          title: 'Kategori',
          subtitle: 'Kelola kategori pustaka anime',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryManagementScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMoreMenuTile(
          icon: Icons.storage_rounded,
          title: 'Data dan Penyimpanan',
          subtitle: 'Kelola backup, restore, dan cache',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DataStorageScreen()),
            );
          },
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
