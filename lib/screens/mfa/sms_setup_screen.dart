import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:hyperlog/services/auth_service.dart';
import 'package:hyperlog/services/mfa_service.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/glass_card.dart';
import 'package:hyperlog/widgets/app_button.dart';
import 'recovery_codes_screen.dart';

class SmsSetupScreen extends StatefulWidget {
  const SmsSetupScreen({super.key});

  @override
  State<SmsSetupScreen> createState() => _SmsSetupScreenState();
}

class _SmsSetupScreenState extends State<SmsSetupScreen> {
  final MfaService _mfaService = MfaService();
  final AuthService _authService = AuthService();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _step = 0; // 0: reauthenticate, 1: phone number, 2: verify code
  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneNumber;
  String? _verificationId;

  Future<void> _reauthenticate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final providers = _authService.getLinkedProviders();
      if (providers.contains('google.com')) {
        await _authService.reauthenticateWithGoogle();
      } else {
        final password = _passwordController.text;
        if (password.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter your password';
            _isLoading = false;
          });
          return;
        }
        final email = _authService.getCurrentUser()?.email;
        if (email == null) throw Exception('No email found');
        await _authService.reauthenticateWithPassword(email, password);
      }

      if (mounted) {
        setState(() {
          _step = 1;
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

  Future<void> _sendVerificationCode() async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      setState(() => _errorMessage = 'Please enter a phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verificationId =
          await _mfaService.startSmsEnrollment(_phoneNumber!);
      if (mounted) {
        setState(() {
          _verificationId = verificationId;
          _step = 2;
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
      await _mfaService.finalizeSmsEnrollment(_verificationId!, code);
      if (mounted) {
        // Navigate to recovery codes screen (generates and displays codes)
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RecoveryCodesScreen(isInitialSetup: true),
          ),
        );
        if (mounted) Navigator.pop(context, true);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message ?? 'Invalid code';
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

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Set Up SMS', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _step == 0
            ? _buildReauthStep()
            : _step == 1
                ? _buildPhoneStep()
                : _buildVerifyStep(),
      ),
    );
  }

  Widget _buildReauthStep() {
    final providers = _authService.getLinkedProviders();
    final hasGoogle = providers.contains('google.com');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Confirm your identity', style: AppTypography.h4),
              const SizedBox(height: 8),
              Text(
                'Before setting up SMS verification, please verify your identity.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),
              if (hasGoogle)
                PrimaryButton(
                  label: 'Continue with Google',
                  onPressed: _isLoading ? null : _reauthenticate,
                  isLoading: _isLoading,
                )
              else ...[
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: AppTypography.body.copyWith(color: AppColors.white),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: AppTypography.bodySmall
                        .copyWith(color: AppColors.whiteDarker),
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
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: _isLoading ? null : _reauthenticate,
                  isLoading: _isLoading,
                ),
              ],
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(_errorMessage!),
        ],
      ],
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter your phone number', style: AppTypography.h4),
              const SizedBox(height: 8),
              Text(
                "We'll send a verification code to this number when you sign in.",
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: AppTypography.bodySmall
                      .copyWith(color: AppColors.whiteDarker),
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
                  counterText: '',
                ),
                style: AppTypography.body.copyWith(color: AppColors.white),
                dropdownTextStyle:
                    AppTypography.body.copyWith(color: AppColors.white),
                initialCountryCode: 'GB',
                onChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Send Code',
                onPressed: _isLoading ? null : _sendVerificationCode,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(_errorMessage!),
        ],
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.sms, size: 48, color: AppColors.denimLight),
              const SizedBox(height: 16),
              Text(
                'Enter verification code',
                style: AppTypography.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A code has been sent to $_phoneNumber',
                style: AppTypography.bodySmall,
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
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Verify & Activate',
                onPressed: _isLoading ? null : _verifyCode,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(_errorMessage!),
        ],
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style:
                  AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
