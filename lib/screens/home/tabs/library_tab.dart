import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/anime_model.dart';
import '../../../models/library_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../services/library_service.dart';
import '../../../utils/responsive.dart';
import '../../../utils/model_converter.dart';
import '../widgets/anime_card.dart';
import '../../detail_screen.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab>
    with AutomaticKeepAliveClientMixin {
  late String _selectedCategoryId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = 'favorit';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<LibraryNotifier>(
      builder: (context, library, _) {
        final categories = library.categories;
        final selectedCategory =
            library.getCategoryById(_selectedCategoryId) ??
            (categories.isNotEmpty ? categories.first : null);

        if (categories.isEmpty) {
          return _buildEmptyState(context);
        }

        return SafeArea(
          child: Column(
            children: [
              // Category Tabs
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      // Add new category button
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: GestureDetector(
                          onTap: () => _showAddCategoryDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final category = categories[index];
                    final isSelected = category.id == _selectedCategoryId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                        },
                        onLongPress: () {
                          if (category.id.toLowerCase() != 'favorit') {
                            _showDeleteCategoryDialog(context, category);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Content
              Expanded(
                child:
                    selectedCategory != null &&
                        selectedCategory.items.isNotEmpty
                    ? _buildAnimeGrid(selectedCategory.items)
                    : _buildCategoryEmpty(selectedCategory?.name ?? ''),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 48, color: AppColors.primary),
              onPressed: () => _showAddCategoryDialog(context),
            ),
          ),
          const SizedBox(height: 24),
          Text('Belum ada kategori custom', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kategori untuk mengelompokkan\nanime favoritmu',
            textAlign: TextAlign.center,
            style: AppTextStyles.textSecondary,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showAddCategoryDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Buat Kategori Pertama',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryEmpty(String categoryName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Kategori "$categoryName" masih kosong',
            style: AppTextStyles.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeGrid(List<LibraryItem> items) {
    return GridView.builder(
      padding: EdgeInsets.all(Responsive.paddingMedium(context)),
      gridDelegate: Responsive.gridDelegateSmall(context),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final animeModel = item.toAnimeModel();
        return AnimeCard(
          anime: animeModel,
          onTap: () => _openDetail(animeModel),
          enableShadow: true,
        );
      },
    );
  }

  void _openDetail(AnimeModel animeModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          malId: animeModel.malId,
          animeInfo: {
            'title': animeModel.title,
            'imageUrl': animeModel.imageUrl,
            'score': animeModel.score,
          },
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final library = context.read<LibraryNotifier>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        title: const Text(
          'Buat Kategori Baru',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Nama kategori',
            hintStyle: const TextStyle(color: AppColors.textHint),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final categoryName = controller.text.trim();
              if (categoryName.isNotEmpty) {
                final success = await library.createCategory(categoryName);
                if (success) {
                  setState(() {
                    _selectedCategoryId = categoryName.toLowerCase();
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kategori sudah ada'),
                        backgroundColor: AppColors.error,
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(
              'Buat',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        title: const Text(
          'Hapus Kategori?',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Kategori "${category.name}" akan dihapus (anime tetap tersimpan di kategori lain)',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<LibraryNotifier>().deleteCategory(category.id);
              setState(() {
                if (_selectedCategoryId == category.id) {
                  _selectedCategoryId = 'favorit';
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kategori dihapus'),
                  backgroundColor: AppColors.darkSurface,
                  duration: Duration(milliseconds: 800),
                ),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
