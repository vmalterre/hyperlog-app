import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/photo_service.dart';
import '../services/pilot_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import 'mfa/two_factor_settings_screen.dart';
import '../services/mfa_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  final PhotoService _photoService = PhotoService();
  final PilotService _pilotService = PilotService();
  final MfaService _mfaService = MfaService();
  bool _isLoading = false;
  bool _mfaEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadMfaStatus();
  }

  Future<void> _loadMfaStatus() async {
    final enabled = await _mfaService.hasMfaEnabled();
    if (mounted) setState(() => _mfaEnabled = enabled);
  }

  List<String> get _providers => _authService.getLinkedProviders();
  bool get _hasPassword => _providers.contains('password');
  bool get _hasGoogle => _providers.contains('google.com');

  String? get _email => _authService.getCurrentUser()?.email;
  DateTime? get _createdAt => _authService.getCurrentUser()?.metadata.creationTime;

  // ==========================================
  // Sign-In Method Actions
  // ==========================================

  Future<void> _setupEmailPassword() async {
    final email = _email;
    if (email == null) return;

    final result = await _showSetupPasswordDialog();
    if (result == null) return;

    setState(() => _isLoading = true);
    try {
      await _authService.linkEmailPassword(email, result);
      if (mounted) {
        setState(() {});
        _showSnackBar('Email & password sign-in added', isError: false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackBar(e.message ?? 'Failed to set up password');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to set up password: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _connectGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.linkGoogle();
      if (mounted) {
        setState(() {});
        _showSnackBar('Google account connected', isError: false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackBar(e.message ?? 'Failed to connect Google');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to connect Google: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _disconnectGoogle() async {
    if (!_hasPassword) {
      _showSnackBar('Set up a password first before disconnecting Google');
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'Disconnect Google?',
      message: 'You will no longer be able to sign in with Google. '
          'You can still sign in with your email and password.',
      confirmLabel: 'Disconnect',
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      // Revoke OAuth token on Google's side (removes from "Third-party apps")
      await GoogleSignIn().disconnect();
      // Unlink provider from Firebase Auth
      await _authService.unlinkProvider('google.com');
      if (mounted) {
        setState(() {});
        _showSnackBar('Google account disconnected', isError: false);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to disconnect Google: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // Security Actions
  // ==========================================

  Future<void> _changePassword() async {
    final result = await _showChangePasswordDialog();
    if (result == null) return;

    setState(() => _isLoading = true);
    try {
      // Reauthenticate first
      await _authService.reauthenticateWithPassword(_email!, result['current']!);
      await _authService.updatePassword(result['new']!);
      if (mounted) _showSnackBar('Password updated successfully', isError: false);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackBar(e.message ?? 'Failed to change password');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to change password: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPasswordViaEmail() async {
    final email = _email;
    if (email == null) return;

    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        _showSnackBar('Password reset email sent to $email', isError: false);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to send reset email: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // Profile Photo Actions
  // ==========================================

  void _showPhotoOptions() {
    final sessionState = Provider.of<SessionState>(context, listen: false);
    final hasPhoto = sessionState.currentPilot?.photoUrl != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.nightRiderDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.whiteDarker,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.denimLight),
              title: Text('Take Photo', style: AppTypography.body.copyWith(color: AppColors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.denimLight),
              title: Text('Choose from Gallery', style: AppTypography.body.copyWith(color: AppColors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPhoto(fromCamera: false);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                title: Text('Remove Photo', style: AppTypography.body.copyWith(color: AppColors.errorRed)),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto({required bool fromCamera}) async {
    final File? file;
    try {
      file = fromCamera
          ? await _photoService.takePhoto()
          : await _photoService.pickFromGallery();
    } catch (e) {
      if (mounted) _showSnackBar('Failed to pick photo: $e');
      return;
    }
    if (file == null) return;

    final sessionState = Provider.of<SessionState>(context, listen: false);
    final userId = sessionState.userId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final downloadUrl = await _photoService.uploadProfilePhoto(file);
      await _pilotService.updateProfilePhotoUrl(userId, downloadUrl);
      await sessionState.refreshPilot();
      if (mounted) _showSnackBar('Profile photo updated', isError: false);
    } catch (e) {
      if (mounted) _showSnackBar('Failed to upload photo: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removePhoto() async {
    final sessionState = Provider.of<SessionState>(context, listen: false);
    final userId = sessionState.userId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      await _photoService.deleteProfilePhoto();
      await _pilotService.updateProfilePhotoUrl(userId, null);
      await sessionState.refreshPilot();
      if (mounted) _showSnackBar('Profile photo removed', isError: false);
    } catch (e) {
      if (mounted) _showSnackBar('Failed to remove photo: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // Data & Privacy Actions
  // ==========================================

  // ==========================================
  // Dialogs
  // ==========================================

  Future<String?> _showSetupPasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.nightRiderDark,
          title: Text('Set Up Password', style: AppTypography.h4),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create a password for $_email',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(passwordController, 'New Password'),
              const SizedBox(height: 12),
              _buildPasswordField(confirmController, 'Confirm Password'),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: AppTypography.caption.copyWith(color: AppColors.errorRed)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.whiteDarker)),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text.length < 6) {
                  setDialogState(() => error = 'Password must be at least 6 characters');
                  return;
                }
                if (passwordController.text != confirmController.text) {
                  setDialogState(() => error = 'Passwords do not match');
                  return;
                }
                Navigator.pop(context, passwordController.text);
              },
              child: Text('Set Up', style: TextStyle(color: AppColors.denimLight)),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>?> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.nightRiderDark,
          title: Text('Change Password', style: AppTypography.h4),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPasswordField(currentController, 'Current Password'),
              const SizedBox(height: 12),
              _buildPasswordField(newController, 'New Password'),
              const SizedBox(height: 12),
              _buildPasswordField(confirmController, 'Confirm New Password'),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: AppTypography.caption.copyWith(color: AppColors.errorRed)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.whiteDarker)),
            ),
            TextButton(
              onPressed: () {
                if (currentController.text.isEmpty) {
                  setDialogState(() => error = 'Enter your current password');
                  return;
                }
                if (newController.text.length < 6) {
                  setDialogState(() => error = 'New password must be at least 6 characters');
                  return;
                }
                if (newController.text != confirmController.text) {
                  setDialogState(() => error = 'New passwords do not match');
                  return;
                }
                Navigator.pop(context, {
                  'current': currentController.text,
                  'new': newController.text,
                });
              },
              child: Text('Change', style: TextStyle(color: AppColors.denimLight)),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(title, style: AppTypography.h4),
        content: Text(message, style: AppTypography.body.copyWith(color: AppColors.whiteDarker)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.whiteDarker)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: TextStyle(color: isDangerous ? AppColors.errorRed : AppColors.denimLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: AppTypography.body.copyWith(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.whiteDarker),
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
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.endorsedGreen,
      ),
    );
  }

  // ==========================================
  // Build
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Account', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email & member since
                _buildIdentityCard(),
                const SizedBox(height: 24),

                // Sign-in methods
                _buildSectionLabel('SIGN-IN METHODS'),
                _buildSignInMethodsCard(),
                const SizedBox(height: 24),

                // Security
                _buildSectionLabel('SECURITY'),
                _buildSecurityCard(),
                const SizedBox(height: 24),

                // Data & Privacy
                _buildSectionLabel('DATA & PRIVACY'),
                _buildDataPrivacyCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.denimLight),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: AppTypography.label),
    );
  }

  Widget _buildIdentityCard() {
    final memberSince = _createdAt != null
        ? DateFormat('MMMM yyyy').format(_createdAt!)
        : 'Unknown';
    final photoUrl = Provider.of<SessionState>(context).currentPilot?.photoUrl;

    return SizedBox(
      width: double.infinity,
      child: GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Tappable avatar with camera badge
          GestureDetector(
            onTap: _showPhotoOptions,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                // Avatar with denim border
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.denim.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.nightRiderDark,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: photoUrl != null
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 36,
                              color: AppColors.denimLight,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 36,
                            color: AppColors.denimLight,
                          ),
                  ),
                ),
                // Camera badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.denim,
                      border: Border.all(color: AppColors.nightRiderDark, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Email
          Text(
            _email ?? 'No email',
            style: AppTypography.body.copyWith(color: AppColors.white),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Member since
          Text(
            'Member since $memberSince',
            style: AppTypography.caption,
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSignInMethodsCard() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Email & Password row
          _buildProviderToggleRow(
            icon: Icons.lock_outline,
            title: 'Email & Password',
            subtitle: _hasPassword ? _email : null,
            isEnabled: _hasPassword,
            onToggle: (value) {
              if (value && !_hasPassword) {
                _setupEmailPassword();
              }
              // Don't allow disabling password if it's the only provider
            },
            canDisable: false,
          ),
          Divider(height: 1, color: AppColors.borderSubtle, indent: 56),
          // Google row
          _buildProviderToggleRow(
            icon: Icons.g_mobiledata,
            title: 'Google',
            subtitle: _hasGoogle ? _email : null,
            isEnabled: _hasGoogle,
            onToggle: (value) {
              if (value) {
                _connectGoogle();
              } else {
                _disconnectGoogle();
              }
            },
            canDisable: _hasPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderToggleRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    bool canDisable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                Text(title, style: AppTypography.body.copyWith(color: AppColors.white)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: _isLoading
                ? null
                : (value) {
                    if (!value && !canDisable) return;
                    onToggle(value);
                  },
            activeColor: AppColors.endorsedGreen,
            activeTrackColor: AppColors.endorsedGreen.withValues(alpha: 0.4),
            inactiveThumbColor: AppColors.whiteDarker,
            inactiveTrackColor: AppColors.nightRiderLight.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (_hasPassword)
            _buildActionRow(
              icon: Icons.key,
              title: 'Change Password',
              onTap: _changePassword,
            ),
          if (_hasPassword)
            Divider(height: 1, color: AppColors.borderSubtle, indent: 56),
          _buildActionRow(
            icon: Icons.email_outlined,
            title: 'Reset Password via Email',
            onTap: _resetPasswordViaEmail,
          ),
          Divider(height: 1, color: AppColors.borderSubtle, indent: 56),
          _buildActionRow(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: _mfaEnabled ? 'Enabled' : 'Not set up',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TwoFactorSettingsScreen()),
              );
              if (mounted) _loadMfaStatus(); // Refresh subtitle
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final session = Provider.of<SessionState>(context, listen: false);
    final userId = session.userId;
    if (userId == null) return;

    // First confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: const Text('Delete Account', style: TextStyle(color: AppColors.errorRed)),
        content: const Text(
          'This will permanently delete your personal data (name, email, photo). '
          'Any blockchain flight records will remain but will no longer be linked to your identity.\n\n'
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      // GDPR-anonymize in PostgreSQL
      await _pilotService.deleteUserAccount(userId);
      // Delete Firebase Auth account
      await FirebaseAuth.instance.currentUser?.delete();
      // Sign out and clear session
      if (mounted) {
        await session.logOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDataPrivacyCard() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your data',
            titleColor: AppColors.errorRed,
            iconColor: AppColors.errorRed,
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool enabled = true,
    Color? titleColor,
    Color? iconColor,
  }) {
    final effectiveColor = enabled
        ? (titleColor ?? AppColors.white)
        : AppColors.whiteDarker.withValues(alpha: 0.5);
    final effectiveIconColor = enabled
        ? (iconColor ?? AppColors.denimLight)
        : AppColors.whiteDarker.withValues(alpha: 0.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.denim).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: effectiveIconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(color: effectiveColor),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.whiteDarker.withValues(alpha: enabled ? 1.0 : 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (enabled && onTap != null)
                Icon(Icons.chevron_right, size: 20, color: AppColors.whiteDarker),
            ],
          ),
        ),
      ),
    );
  }
}
