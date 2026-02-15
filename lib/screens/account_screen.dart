import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/auth_service.dart';
import '../services/pilot_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  final PilotService _pilotService = PilotService();
  bool _isLoading = false;

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
  // Data & Privacy Actions
  // ==========================================

  Future<void> _exportData() async {
    final userId = Provider.of<SessionState>(context, listen: false).userId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await _pilotService.exportUserData(userId);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      if (mounted) {
        // Write to temp file and share
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/hyperlog_data_export.json');
        await file.writeAsString(jsonStr);
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'HyperLog Data Export',
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to export data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final userId = Provider.of<SessionState>(context, listen: false).userId;
    if (userId == null) return;

    // Step 1: Warning dialog
    final wantsToDelete = await _showConfirmDialog(
      title: 'Delete Account?',
      message: 'This will permanently delete your account and all associated data. '
          'Your personal information will be anonymized. '
          'Blockchain flight records will remain but will no longer be linked to your identity.\n\n'
          'This action cannot be undone.',
      confirmLabel: 'Continue',
      isDangerous: true,
    );
    if (wantsToDelete != true || !mounted) return;

    // Step 2: Type DELETE to confirm
    final confirmed = await _showTypeToConfirmDialog();
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      // Reauthenticate before deletion
      await _reauthenticate();

      // Delete backend data (GDPR anonymization)
      await _pilotService.deleteUserAccount(userId);

      // Delete Firebase Auth account
      await _authService.deleteAccount();

      // Sign out and return to login
      if (mounted) {
        final session = Provider.of<SessionState>(context, listen: false);
        await session.logOut();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackBar(e.message ?? 'Failed to delete account');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to delete account: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reauthenticate() async {
    if (_hasPassword && _hasGoogle) {
      // User has both - let them choose
      final method = await _showReauthMethodDialog();
      if (method == 'password') {
        final password = await _showPasswordPromptDialog();
        if (password == null) throw Exception('Reauthentication cancelled');
        await _authService.reauthenticateWithPassword(_email!, password);
      } else if (method == 'google') {
        await _authService.reauthenticateWithGoogle();
      } else {
        throw Exception('Reauthentication cancelled');
      }
    } else if (_hasPassword) {
      final password = await _showPasswordPromptDialog();
      if (password == null) throw Exception('Reauthentication cancelled');
      await _authService.reauthenticateWithPassword(_email!, password);
    } else if (_hasGoogle) {
      await _authService.reauthenticateWithGoogle();
    }
  }

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

  Future<String?> _showPasswordPromptDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text('Enter Password', style: AppTypography.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your password to continue',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(controller, 'Password'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.whiteDarker)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Continue', style: TextStyle(color: AppColors.denimLight)),
          ),
        ],
      ),
    );
  }

  Future<String?> _showReauthMethodDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text('Verify Identity', style: AppTypography.h4),
        content: Text(
          'Choose how to verify your identity to continue.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.whiteDarker)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'password'),
            child: Text('Use Password', style: TextStyle(color: AppColors.denimLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'google'),
            child: Text('Use Google', style: TextStyle(color: AppColors.denimLight)),
          ),
        ],
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

  Future<bool?> _showTypeToConfirmDialog() {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.nightRiderDark,
          title: Text('Confirm Deletion', style: AppTypography.h4),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Type DELETE to permanently delete your account.',
                style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: AppTypography.body.copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Type DELETE',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.whiteDarker.withValues(alpha: 0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderVisible),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.errorRed),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.nightRider,
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: AppColors.whiteDarker)),
            ),
            TextButton(
              onPressed: controller.text == 'DELETE'
                  ? () => Navigator.pop(context, true)
                  : null,
              child: Text(
                'Delete My Account',
                style: TextStyle(
                  color: controller.text == 'DELETE'
                      ? AppColors.errorRed
                      : AppColors.whiteDarker.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
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

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.denim.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.email_outlined, color: AppColors.denimLight, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _email ?? 'No email',
                  style: AppTypography.body.copyWith(color: AppColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since $memberSince',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInMethodsCard() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Email & Password row
          _buildProviderRow(
            icon: Icons.lock_outline,
            title: 'Email & Password',
            subtitle: _hasPassword ? _email : null,
            isLinked: _hasPassword,
            actionLabel: _hasPassword ? null : 'Set Up',
            onAction: _hasPassword ? null : _setupEmailPassword,
          ),
          Divider(height: 1, color: AppColors.borderSubtle, indent: 56),
          // Google row
          _buildProviderRow(
            icon: Icons.g_mobiledata,
            title: 'Google',
            subtitle: _hasGoogle ? _email : null,
            isLinked: _hasGoogle,
            actionLabel: _hasGoogle ? 'Disconnect' : 'Connect',
            onAction: _hasGoogle ? _disconnectGoogle : _connectGoogle,
            actionColor: _hasGoogle ? AppColors.errorRed : AppColors.denimLight,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isLinked,
    String? actionLabel,
    VoidCallback? onAction,
    Color? actionColor,
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
          if (isLinked && actionLabel == null)
            Icon(Icons.check_circle, size: 20, color: AppColors.endorsedGreen),
          if (isLinked && actionLabel != null) ...[
            Icon(Icons.check_circle, size: 16, color: AppColors.endorsedGreen),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: AppTypography.buttonSmall.copyWith(
                  color: actionColor ?? AppColors.denimLight,
                ),
              ),
            ),
          ],
          if (!isLinked && actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: AppTypography.buttonSmall.copyWith(
                  color: actionColor ?? AppColors.denimLight,
                ),
              ),
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
            subtitle: 'Coming soon',
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacyCard() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.download_outlined,
            title: 'Export My Data',
            onTap: _exportData,
          ),
          Divider(height: 1, color: AppColors.borderSubtle, indent: 56),
          _buildActionRow(
            icon: Icons.delete_forever,
            title: 'Delete Account',
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
