import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../config/theme/app_theme.dart';
import '../services/backup_restore_service.dart';
import '../services/storage_settings_service.dart';
import '../services/hive_service.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  late String _backupLocation;
  late String _autoBackupFrequency;
  bool _isLoading = false;
  bool _isLoadingBackups = false;
  List<FileSystemEntity> _backupFiles = [];
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      final location = await StorageSettingsService.getBackupLocation();
      final frequency = await StorageSettingsService.getAutoBackupFrequency();

      if (mounted) {
        setState(() {
          _backupLocation = location;
          _autoBackupFrequency = frequency;
        });
      }

      await _loadBackupFiles();
    } catch (e) {
      _showError('Failed to load settings: $e');
    }
  }

  Future<void> _loadBackupFiles() async {
    setState(() => _isLoadingBackups = true);

    try {
      final files = await BackupRestoreService.getBackupFiles(_backupLocation);
      if (mounted) {
        setState(() {
          _backupFiles = files;
          _isLoadingBackups = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBackups = false);
        _showError('Failed to load backup files: $e');
      }
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    _clearMessages();

    try {
      final backupPath = await BackupRestoreService.createBackup(
        _backupLocation,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccess('Backup berhasil dibuat:\n${backupPath.split('/').last}');
        await _loadBackupFiles();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Gagal membuat backup: $e');
      }
    }
  }

  Future<void> _restoreBackup(String backupPath) async {
    final confirm = await _showConfirmDialog(
      title: 'Pulihkan Backup',
      message:
          'Data saat ini akan ditimpa dengan data dari backup ini.\n\n'
          'Lanjutkan?',
    );

    if (!confirm) return;

    setState(() => _isLoading = true);
    _clearMessages();

    try {
      await BackupRestoreService.restoreBackup(backupPath);

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccess('Backup berhasil dipulihkan!');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Gagal memulihkan backup: $e');
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final backupPath = result.files.first.path;
        if (backupPath != null) {
          await _restoreBackup(backupPath);
        }
      }
    } catch (e) {
      _showError('Gagal membuka file picker: $e');
    }
  }

  Future<void> _changeBackupLocation() async {
    try {
      final result = await FilePicker.getDirectoryPath();

      if (result != null && result.isNotEmpty) {
        await StorageSettingsService.setBackupLocation(result);
        if (mounted) {
          setState(() => _backupLocation = result);
          _showSuccess('Lokasi backup diubah');
          await _loadBackupFiles();
        }
      }
    } catch (e) {
      _showError('Gagal memilih direktori: $e');
    }
  }

  Future<void> _clearCache() async {
    final confirm = await _showConfirmDialog(
      title: 'Hapus Cache',
      message:
          'Hapus semua cache data anime?\n\n'
          'Data favorit, riwayat, dan kategori akan tetap tersimpan.',
    );

    if (!confirm) return;

    setState(() => _isLoading = true);
    _clearMessages();

    try {
      await HiveService.clearCache();

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccess('Cache berhasil dihapus');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Gagal menghapus cache: $e');
      }
    }
  }

  Future<void> _changeAutoBackupFrequency(String newFrequency) async {
    await StorageSettingsService.setAutoBackupFrequency(newFrequency);
    if (mounted) {
      setState(() => _autoBackupFrequency = newFrequency);
      _showSuccess(
        'Frekuensi pencadangan diatur ke: '
        '${StorageSettingsService.getFrequencyLabel(newFrequency)}',
      );
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(title, style: AppTextStyles.heading4),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Ya',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccess(String message) {
    _clearMessages();
    setState(() => _successMessage = message);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _successMessage = null);
      }
    });
  }

  void _showError(String message) {
    _clearMessages();
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _errorMessage = null);
      }
    });
  }

  void _clearMessages() {
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Data dan Penyimpanan', style: AppTextStyles.heading3),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Messages
                if (_successMessage != null)
                  _buildStatusMessage(
                    _successMessage!,
                    AppColors.success,
                    Icons.check_circle_rounded,
                  ),
                if (_errorMessage != null)
                  _buildStatusMessage(
                    _errorMessage!,
                    AppColors.danger,
                    Icons.error_rounded,
                  ),
                if (_successMessage != null || _errorMessage != null)
                  const SizedBox(height: 16),

                // Backup & Restore Section
                _buildSectionHeader('Pencadangan dan Pemulihan'),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.backup_rounded,
                  title: 'Buat Backup',
                  subtitle: 'Cadangkan semua data',
                  onTap: _isLoading ? null : _createBackup,
                ),
                const SizedBox(height: 10),
                _buildActionButton(
                  icon: Icons.upload_file_rounded,
                  title: 'Impor Backup',
                  subtitle: 'Pilih file backup untuk dipulihkan',
                  onTap: _isLoading ? null : _importBackup,
                ),
                const SizedBox(height: 20),

                // Backup Location Section
                _buildSectionHeader('Lokasi Pencadangan'),
                const SizedBox(height: 12),
                _buildLocationTile(),
                const SizedBox(height: 20),

                // Backup Files Section
                _buildSectionHeader('Backup Tersimpan'),
                const SizedBox(height: 12),
                _buildBackupFilesList(),
                const SizedBox(height: 20),

                // Auto Backup Frequency Section
                _buildSectionHeader('Frekuensi Pencadangan Otomatis'),
                const SizedBox(height: 12),
                _buildFrequencySelector(),
                const SizedBox(height: 20),

                // Cache Cleanup Section
                _buildSectionHeader('Pembersihan Data'),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.delete_sweep_rounded,
                  title: 'Hapus Cache',
                  subtitle: 'Hapus cache data anime yang disimpan',
                  onTap: _isLoading ? null : _clearCache,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.heading4);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.lightGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTile() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lokasi Saat Ini',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: _isLoading ? null : _changeBackupLocation,
                child: Text(
                  'Ubah',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _backupLocation,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupFilesList() {
    if (_isLoadingBackups) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (_backupFiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Belum ada backup',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _backupFiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final file = _backupFiles[index];
        final info = BackupRestoreService.getBackupFileInfo(file.path);

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _restoreBackup(file.path),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.backup_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        info['name'] as String,
                        style: AppTextStyles.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${info['modifiedFormatted']} • ${info['size']}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrequencySelector() {
    final frequencies = [
      (StorageSettingsService.frequencyNone, 'Matikan'),
      (StorageSettingsService.frequencyDaily, 'Tiap hari'),
      (StorageSettingsService.frequency3Days, 'Tiap 3 hari'),
      (StorageSettingsService.frequencyWeekly, 'Tiap minggu'),
      (StorageSettingsService.frequencyMonthly, 'Tiap bulan'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: frequencies.length,
        separatorBuilder: (_, __) => Divider(
          color: AppColors.border,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final (value, label) = frequencies[index];
          final isSelected = _autoBackupFrequency == value;

          return InkWell(
            onTap: _isLoading ? null : () => _changeAutoBackupFrequency(value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium),
                  if (isSelected)
                    Icon(Icons.check_rounded, color: AppColors.primary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusMessage(String message, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
