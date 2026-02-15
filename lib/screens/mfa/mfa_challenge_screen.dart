import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperlog/services/mfa_service.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/glass_card.dart';
import 'package:hyperlog/widgets/app_button.dart';
import 'package:hyperlog/services/api_service.dart';
import 'package:hyperlog/services/api_exception.dart';

/// Screen shown when a user with MFA enabled signs in and needs to provide
/// a second factor.
class MfaChallengeScreen extends StatefulWidget {
  final MultiFactorResolver resolver;
  /// The email used to sign in (needed for recovery code flow).
  final String? email;

  const MfaChallengeScreen({super.key, required this.resolver, this.email});

  @override
  State<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends State<MfaChallengeScreen> {
  final MfaService _mfaService = MfaService();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedFactorId;
  String? _smsVerificationId;

  /// Categorized factors from the resolver
  List<MultiFactorInfo> get _factors => widget.resolver.hints;

  bool get _hasTotpFactor =>
      _factors.any((f) => f.factorId == MfaService.totpFactorId);
  bool get _hasSmsFactor =>
      _factors.any((f) => f.factorId == MfaService.phoneFactorId);

  @override
  void initState() {
    super.initState();
    // Default to TOTP if available, otherwise SMS
    if (_hasTotpFactor) {
      _selectedFactorId = MfaService.totpFactorId;
    } else if (_hasSmsFactor) {
      _selectedFactorId = MfaService.phoneFactorId;
      _sendSmsCode();
    }
  }

  Future<void> _sendSmsCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final smsFactor = _factors.firstWhere(
          (f) => f.factorId == MfaService.phoneFactorId);
      final verificationId =
          await _mfaService.startSmsChallenge(widget.resolver, smsFactor);
      if (mounted) {
        setState(() {
          _smsVerificationId = verificationId;
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

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Enter a 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential credential;

      if (_selectedFactorId == MfaService.totpFactorId) {
        credential =
            await _mfaService.resolveTotpChallenge(widget.resolver, code);
      } else {
        credential = await _mfaService.resolveSmsChallenge(
            widget.resolver, _smsVerificationId!, code);
      }

      if (mounted) {
        Navigator.pop(context, credential.user);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Invalid verification code. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _useRecoveryCode() async {
    final recoveryCode = await _showRecoveryCodeDialog();
    if (recoveryCode == null || recoveryCode.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify recovery code via API, get custom token, sign in
      final apiService = ApiService();
      final response = await apiService.post('/auth/recovery-login', {
        'email': widget.email ?? '',
        'recoveryCode': recoveryCode,
      });

      final customToken = response['data']['customToken'] as String;
      await FirebaseAuth.instance.signInWithCustomToken(customToken);

      if (mounted) {
        Navigator.pop(context, FirebaseAuth.instance.currentUser);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.statusCode == 401
              ? 'Invalid recovery code. Please try again.'
              : 'Recovery login failed: ${e.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Recovery login failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _showRecoveryCodeDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text('Recovery Code', style: AppTypography.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter one of your recovery codes to sign in.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: AppTypography.body.copyWith(
                color: AppColors.white,
                letterSpacing: 2,
              ),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'XXXXXXXX',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.whiteDarker.withValues(alpha: 0.3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.borderVisible),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.denimLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.nightRider,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.whiteDarker)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Verify',
                style: TextStyle(color: AppColors.denimLight)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Verification Required', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Factor selector (if multiple factors available)
            if (_hasTotpFactor && _hasSmsFactor) ...[
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose verification method',
                        style: AppTypography.body
                            .copyWith(color: AppColors.white)),
                    const SizedBox(height: 12),
                    _buildFactorOption(
                      MfaService.totpFactorId,
                      Icons.apps,
                      'Authenticator App',
                    ),
                    const SizedBox(height: 8),
                    _buildFactorOption(
                      MfaService.phoneFactorId,
                      Icons.sms,
                      'SMS Code',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Code entry
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    _selectedFactorId == MfaService.totpFactorId
                        ? Icons.apps
                        : Icons.sms,
                    size: 48,
                    color: AppColors.denimLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFactorId == MfaService.totpFactorId
                        ? 'Enter your authenticator code'
                        : 'Enter the code sent to your phone',
                    style: AppTypography.body.copyWith(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: AppTypography.h3.copyWith(
                      letterSpacing: 8,
                      color: AppColors.white,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      hintStyle: AppTypography.h3.copyWith(
                        letterSpacing: 8,
                        color:
                            AppColors.whiteDarker.withValues(alpha: 0.3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.borderVisible),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.denimLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.nightRider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Verify',
                    onPressed: _isLoading ? null : _verifyCode,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.errorRed, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.errorRed),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Recovery code option
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _useRecoveryCode,
                child: Text(
                  'Use a recovery code instead',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.denimLight,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorOption(String factorId, IconData icon, String label) {
    final isSelected = _selectedFactorId == factorId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFactorId = factorId;
          _codeController.clear();
          _errorMessage = null;
        });
        if (factorId == MfaService.phoneFactorId &&
            _smsVerificationId == null) {
          _sendSmsCode();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.denimLight : AppColors.borderVisible,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.denim.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.denimLight),
            const SizedBox(width: 12),
            Text(label,
                style: AppTypography.body.copyWith(color: AppColors.white)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle,
                  size: 20, color: AppColors.denimLight),
          ],
        ),
      ),
    );
  }
}
