import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyperlog/services/mfa_service.dart';
import 'package:hyperlog/services/biometric_service.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/glass_card.dart';
import 'totp_setup_screen.dart';
import 'sms_setup_screen.dart';
import 'recovery_codes_screen.dart';

class TwoFactorSettingsScreen extends StatefulWidget {
  const TwoFactorSettingsScreen({super.key});

  @override
  State<TwoFactorSettingsScreen> createState() =>
      _TwoFactorSettingsScreenState();
}

class _TwoFactorSettingsScreenState extends State<TwoFactorSettingsScreen> {
  final MfaService _mfaService = MfaService();
  final BiometricService _biometricService = BiometricService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  List<MultiFactorInfo> _factors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final factors = await _mfaService.getEnrolledFactors();
    final biometricAvailable = await _biometricService.isAvailable();
    final biometricEnabled = await _biometricService.isEnabled();
    if (mounted) {
      setState(() {
        _factors = factors;
        _biometricAvailable = biometricAvailable;
        _biometricEnabled = biometricEnabled;
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.endorsedGreen,
      ),
    );
  }

  Future<void> _navigateToTotpSetup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TotpSetupScreen()),
    );
    if (result == true && mounted) {
      await _loadState();
      _showSnackBar('Authenticator app set up successfully', isError: false);
    }
  }

  Future<void> _navigateToSmsSetup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SmsSetupScreen()),
    );
    if (result == true && mounted) {
      await _loadState();
      _showSnackBar('SMS verification set up successfully', isError: false);
    }
  }

  Future<void> _navigateToRecoveryCodes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecoveryCodesScreen()),
    );
  }

  Future<void> _disableFactor(MultiFactorInfo factor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text('Disable ${factor.displayName ?? 'Factor'}?',
            style: AppTypography.h4),
        content: Text(
          'You will no longer be prompted for this second factor when signing in.',
          style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.whiteDarker)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Disable',
                style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _mfaService.unenrollFactor(factor);
      if (mounted) {
        await _loadState();
        _showSnackBar('${factor.displayName ?? 'Factor'} disabled',
            isError: false);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to disable: $e');
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    await _biometricService.setEnabled(value);
    if (mounted) {
      setState(() => _biometricEnabled = value);
    }
  }

  bool get _hasTotp =>
      _factors.any((f) => f.factorId == MfaService.totpFactorId);
  bool get _hasSms =>
      _factors.any((f) => f.factorId == MfaService.phoneFactorId);
  bool get _hasMfa => _factors.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.nightRider,
        appBar: AppBar(
          backgroundColor: AppColors.nightRider,
          elevation: 0,
          title: Text('Two-Factor Authentication', style: AppTypography.h3),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.denimLight),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Two-Factor Authentication', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _hasMfa ? Icons.verified_user : Icons.shield_outlined,
                    color: _hasMfa
                        ? AppColors.endorsedGreen
                        : AppColors.whiteDarker,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasMfa ? 'Two-factor is enabled' : 'Two-factor is off',
                          style: AppTypography.body
                              .copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _hasMfa
                              ? '${_factors.length} factor${_factors.length > 1 ? 's' : ''} enrolled'
                              : 'Add a second factor to secure your account',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Authentication Methods
            _buildSectionLabel('AUTHENTICATION METHODS'),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // TOTP
                  _buildFactorRow(
                    icon: Icons.apps,
                    title: 'Authenticator App',
                    subtitle: _hasTotp ? 'Enabled' : 'Not set up',
                    isEnabled: _hasTotp,
                    onSetup: _hasTotp ? null : _navigateToTotpSetup,
                    onDisable: _hasTotp
                        ? () {
                            final totpFactor = _factors.firstWhere(
                                (f) => f.factorId == MfaService.totpFactorId);
                            _disableFactor(totpFactor);
                          }
                        : null,
                  ),
                  Divider(
                      height: 1,
                      color: AppColors.borderSubtle,
                      indent: 56),
                  // SMS
                  _buildFactorRow(
                    icon: Icons.sms,
                    title: 'SMS Verification',
                    subtitle: _hasSms ? 'Enabled' : 'Not set up',
                    isEnabled: _hasSms,
                    onSetup: _hasSms ? null : _navigateToSmsSetup,
                    onDisable: _hasSms
                        ? () {
                            final smsFactor = _factors.firstWhere(
                                (f) => f.factorId == MfaService.phoneFactorId);
                            _disableFactor(smsFactor);
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Biometric
            if (_biometricAvailable) ...[
              _buildSectionLabel('DEVICE SECURITY'),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.denim.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.fingerprint,
                            size: 20, color: AppColors.denimLight),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Biometric Lock',
                                style: AppTypography.body
                                    .copyWith(color: AppColors.white)),
                            const SizedBox(height: 2),
                            Text(
                              'Require biometric for sensitive actions',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _biometricEnabled,
                        onChanged: _toggleBiometric,
                        activeColor: AppColors.denimLight,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Recovery Codes
            if (_hasMfa) ...[
              _buildSectionLabel('BACKUP'),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToRecoveryCodes,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.denim.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.vpn_key,
                                size: 20, color: AppColors.denimLight),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Recovery Codes',
                                    style: AppTypography.body
                                        .copyWith(color: AppColors.white)),
                                const SizedBox(height: 2),
                                Text(
                                  'View or regenerate backup codes',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 20, color: AppColors.whiteDarker),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: AppTypography.label),
    );
  }

  Widget _buildFactorRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    VoidCallback? onSetup,
    VoidCallback? onDisable,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.denim.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.denimLight),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        AppTypography.body.copyWith(color: AppColors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          if (isEnabled) ...[
            const Icon(Icons.check_circle,
                size: 16, color: AppColors.endorsedGreen),
            const SizedBox(width: 8),
            if (onDisable != null)
              GestureDetector(
                onTap: onDisable,
                child: Text('Disable',
                    style: AppTypography.buttonSmall
                        .copyWith(color: AppColors.errorRed)),
              ),
          ],
          if (!isEnabled && onSetup != null)
            GestureDetector(
              onTap: onSetup,
              child: Text('Set Up',
                  style: AppTypography.buttonSmall
                      .copyWith(color: AppColors.denimLight)),
            ),
        ],
      ),
    );
  }
}
