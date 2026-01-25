import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/import_models.dart';
import '../../../services/import_service.dart';
import '../../../session_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/glass_card.dart';
import 'import_preview_screen.dart';

/// Screen for selecting import provider and CSV file
class ImportProviderScreen extends StatefulWidget {
  const ImportProviderScreen({super.key});

  @override
  State<ImportProviderScreen> createState() => _ImportProviderScreenState();
}

class _ImportProviderScreenState extends State<ImportProviderScreen> {
  ImportProvider _selectedProvider = ImportProvider.flylog;
  File? _selectedFile;
  String? _fileName;
  bool _isAnalyzing = false;
  String? _error;

  final _importService = ImportService();

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedFile = File(file.path!);
            _fileName = file.name;
            _error = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _analyzeFile() async {
    if (_selectedFile == null) return;

    final session = Provider.of<SessionState>(context, listen: false);
    final userId = session.currentPilot?.id;

    if (userId == null) {
      setState(() {
        _error = 'No user logged in';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final analysis = await _importService.analyzeImport(
        userId: userId,
        provider: _selectedProvider,
        file: _selectedFile!,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImportPreviewScreen(analysis: analysis),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _importService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Import Logbook', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider selection section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text('SELECT PROVIDER', style: AppTypography.label),
            ),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose the logbook app you want to import from.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...ImportProvider.values.map((provider) => _ProviderOption(
                        provider: provider,
                        isSelected: _selectedProvider == provider,
                        onTap: () {
                          setState(() {
                            _selectedProvider = provider;
                          });
                        },
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // File selection section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text('SELECT CSV FILE', style: AppTypography.label),
            ),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export your logbook from ${_selectedProvider.displayName} as a CSV file, then select it here.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedFile != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.glassDark90,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.denim.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.description,
                            color: AppColors.denim,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fileName ?? 'CSV File',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Ready to analyze',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.endorsedGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.whiteDarker),
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                                _fileName = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SecondaryButton(
                    label: _selectedFile == null ? 'Choose File' : 'Change File',
                    icon: Icons.folder_open,
                    fullWidth: true,
                    onPressed: _pickFile,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppTypography.bodySmall.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Analyze button
            PrimaryButton(
              label: 'Analyze File',
              icon: Icons.analytics,
              fullWidth: true,
              isLoading: _isAnalyzing,
              onPressed: _selectedFile != null ? _analyzeFile : null,
            ),
            const SizedBox(height: 16),

            // Info text
            Text(
              'Your flights will be previewed before import. No data will be created until you confirm.',
              style: AppTypography.caption.copyWith(
                color: AppColors.whiteDarker,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider option widget
class _ProviderOption extends StatelessWidget {
  final ImportProvider provider;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderOption({
    required this.provider,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.denim : AppColors.whiteDarker,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.denim,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.displayName,
                    style: AppTypography.body.copyWith(
                      color: isSelected ? AppColors.white : AppColors.whiteDarker,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    provider.description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
