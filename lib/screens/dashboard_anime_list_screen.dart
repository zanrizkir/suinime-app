import 'package:flutter/material.dart';

import '../config/theme/app_theme.dart';
import 'home/tabs/dashboard_tab.dart';

class DashboardAnimeListScreen extends StatelessWidget {
  final String title;
  final String filter;

  const DashboardAnimeListScreen({
    super.key,
    required this.title,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: DashboardTab(
        filter: filter,
        onTopAnimeSeeAll: () {},
        onLatestAnimeSeeAll: () {},
      ),
    );
  }
}
