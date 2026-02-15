import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hyperlog/services/api_service.dart';
import 'package:hyperlog/session_state.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/glass_card.dart';
import 'package:hyperlog/widgets/app_button.dart';

class RecoveryCodesScreen extends StatefulWidget {
  /// If true, this is the first time showing codes after MFA enrollment.
  final bool isInitialSetup;

  const RecoveryCodesScreen({super.key, this.isInitialSetup = false});

  @override
  State<RecoveryCodesScreen> createState() => _RecoveryCodesScreenState();
}

class _RecoveryCodesScreenState extends State<RecoveryCodesScreen> {
  final ApiService _apiService = ApiService();

  List<String>? _codes;
  int? _remainingCount;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isInitialSetup) {
      _generateCodes();
    } else {
      _loadRemainingCount();
    }
  }

  String? get _userId =>
      Provider.of<SessionState>(context, listen: false).userId;

  Future<void> _generateCodes() async {
    final userId = _userId;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.post(
        '/users/$userId/recovery-codes/generate',
        {},
      );
      final codes = (response['data']['codes'] as List)
          .map((c) => c.toString())
          .toList();
      if (mounted) {
        setState(() {
          _codes = codes;
          _remainingCount = codes.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRemainingCount() async {
    final userId = _userId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.get(
        '/users/$userId/recovery-codes/count',
      );
      if (mounted) {
        setState(() {
          _remainingCount = response['data']['remaining'] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _remainingCount = 0;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _regenerateCodes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text('Regenerate Codes?', style: AppTypography.h4),
        content: Text(
          'This will invalidate all existing recovery codes and generate new ones.',
          style:
              AppTypography.body.copyWith(color: AppColors.whiteDarker),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancel', style: TextStyle(color: AppColors.whiteDarker)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Regenerate',
                style: TextStyle(color: AppColors.denimLight)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _generateCodes();
    }
  }

  void _copyAll() {
    if (_codes == null) return;
    final text = _codes!.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recovery codes copied to clipboard'),
        backgroundColor: AppColors.endorsedGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Recovery Codes', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.denimLight))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning banner (only on initial setup)
                  if (widget.isInitialSetup) Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber,
                            color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Save these codes in a safe place. Each code can only be used once. If you lose access to your authenticator app, you can use these codes to sign in.',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isInitialSetup) const SizedBox(height: 24),

                  if (_codes != null) ...[
                    // Codes grid
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 2-column grid of codes
                          for (int i = 0; i < _codes!.length; i += 2)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _codes![i],
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.white,
                                        fontFamily: 'monospace',
                                        letterSpacing: 2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (i + 1 < _codes!.length)
                                    Expanded(
                                      child: Text(
                                        _codes![i + 1],
                                        style: AppTypography.body.copyWith(
                                          color: AppColors.white,
                                          fontFamily: 'monospace',
                                          letterSpacing: 2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Copy button
                          SecondaryButton(
                            label: 'Copy All',
                            icon: Icons.copy,
                            onPressed: _copyAll,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Show remaining count when codes aren't displayed
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.vpn_key,
                            size: 48,
                            color: _remainingCount != null &&
                                    _remainingCount! > 0
                                ? AppColors.denimLight
                                : AppColors.errorRed,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_remainingCount ?? 0} codes remaining',
                            style: AppTypography.h4,
                          ),
                          const SizedBox(height: 4),
                          const SizedBox(height: 4),
                          Text(
                            _remainingCount != null && _remainingCount! > 0
                                ? 'Codes are only shown once when generated.\nIf you lost them, regenerate new ones.'
                                : 'Regenerate codes to create new ones',
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Regenerate button
                  SecondaryButton(
                    label: 'Regenerate Codes',
                    icon: Icons.refresh,
                    onPressed: _regenerateCodes,
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color:
                                AppColors.errorRed.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.errorRed),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
