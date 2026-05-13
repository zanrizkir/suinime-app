import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme/app_theme.dart';
import '../models/library_model.dart';
import '../services/library_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  late List<String> _categoryOrder;

  @override
  void initState() {
    super.initState();
    final library = context.read<LibraryNotifier>();
    _categoryOrder = library.categories.map((c) => c.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Kelola Kategori',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: Consumer<LibraryNotifier>(
        builder: (context, library, _) {
          final categories = library.categories;

          if (categories.isEmpty) {
            return _buildEmptyState(context, library);
          }

          return Column(
            children: [
              Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _categoryOrder.removeAt(oldIndex);
                      _categoryOrder.insert(newIndex, item);

                      // Update categories order in library
                      final reorderedCategories = _categoryOrder
                          .map(
                            (id) =>
                                categories.firstWhere((cat) => cat.id == id),
                          )
                          .toList();
                      library.reorderCategories(reorderedCategories);
                    });
                  },
                  children: [
                    for (int i = 0; i < categories.length; i++)
                      _buildCategoryTile(
                        key: ValueKey(categories[i].id),
                        context: context,
                        category: categories[i],
                        library: library,
                        isProtected:
                            categories[i].id.toLowerCase() == 'favorit',
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showAddCategoryDialog(context, library),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: AppColors.white),
                          SizedBox(width: 8),
                          Text(
                            'Tambah Kategori',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, LibraryNotifier library) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 24),
          Text('Belum ada kategori', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kategori untuk mengelompokkan\nanime favoritmu',
            textAlign: TextAlign.center,
            style: AppTextStyles.textSecondary,
          ),
          const SizedBox(height: 32),
          Container(
            width: 160,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showAddCategoryDialog(context, library),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.white),
                    SizedBox(width: 8),
                    Text(
                      'Buat Kategori',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required Key key,
    required BuildContext context,
    required LibraryCategory category,
    required LibraryNotifier library,
    required bool isProtected,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        leading: Icon(Icons.drag_handle, color: AppColors.textTertiary),
        title: Text(
          category.name,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${category.items.length} item${category.items.length != 1 ? 's' : ''}',
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        ),
        trailing: isProtected
            ? Tooltip(
                message: 'Kategori default',
                child: Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              )
            : PopupMenuButton(
                color: AppColors.darkSurface,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Ubah Nama',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ],
                    ),
                    onTap: () =>
                        _showRenameCategoryDialog(context, category, library),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                    onTap: () =>
                        _showDeleteCategoryDialog(context, category, library),
                  ),
                ],
              ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, LibraryNotifier library) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Buat Kategori Baru',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
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
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                if (await library.createCategory(name)) {
                  setState(() {
                    _categoryOrder.add(name.toLowerCase());
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kategori "$name" dibuat'),
                        backgroundColor: AppColors.success,
                        duration: const Duration(milliseconds: 1000),
                      ),
                    );
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

  void _showRenameCategoryDialog(
    BuildContext context,
    LibraryCategory category,
    LibraryNotifier library,
  ) {
    final TextEditingController controller = TextEditingController(
      text: category.name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Ubah Nama Kategori',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Nama kategori baru',
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
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != category.name) {
                if (await library.renameCategory(category.id, newName)) {
                  setState(() {
                    final idx = _categoryOrder.indexOf(category.id);
                    if (idx != -1) {
                      _categoryOrder[idx] = newName.toLowerCase();
                    }
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kategori diubah menjadi "$newName"'),
                        backgroundColor: AppColors.success,
                        duration: const Duration(milliseconds: 1000),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama kategori sudah ada'),
                        backgroundColor: AppColors.error,
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(
              'Ubah',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    LibraryCategory category,
    LibraryNotifier library,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Hapus Kategori?',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Kategori "${category.name}" akan dihapus. Anime di dalamnya tidak akan dihapus dari pustaka.',
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
            onPressed: () async {
              await library.deleteCategory(category.id);
              setState(() {
                _categoryOrder.removeWhere((id) => id == category.id);
              });
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kategori "${category.name}" dihapus'),
                    backgroundColor: AppColors.darkSurface,
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
              }
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
