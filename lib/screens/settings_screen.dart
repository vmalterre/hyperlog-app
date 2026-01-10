import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:hyperlog/session_state.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/glass_card.dart';
import 'package:hyperlog/widgets/app_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionState>(context);
    final pilot = session.currentPilot;
    final pilotLoadError = session.pilotLoadError;
    final displayName = pilot?.displayName ?? 'Pilot Account';
    final email = pilot?.email ?? '';
    final photoUrl = pilot?.photoUrl;
    final isOfficial = pilot?.isOfficialTier ?? false;

    return Scaffold(
      backgroundColor: AppColors.nightRider,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Settings', style: AppTypography.h2(context)),
              const SizedBox(height: 4),
              Text(
                'Manage your account',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 32),

              // Profile card
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Avatar - photo or placeholder
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.denim.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.denim.withValues(alpha: 0.3),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: photoUrl != null
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 32,
                                color: AppColors.denim,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 32,
                              color: AppColors.denim,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: AppTypography.h4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Subscription tier badge
                              _SubscriptionBadge(isOfficial: isOfficial),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: AppTypography.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (pilotLoadError != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Error: $pilotLoadError',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.errorRed,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.whiteDarker,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account settings
              _SettingsSection(
                title: 'ACCOUNT',
                items: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Data settings
              _SettingsSection(
                title: 'DATA',
                items: [
                  _SettingsItem(
                    icon: Icons.download_outlined,
                    title: 'Export Logbook',
                    subtitle: 'PDF, CSV, or EASA format',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.sync_outlined,
                    title: 'Sync Status',
                    subtitle: 'Last synced: Just now',
                    trailing: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.endorsedGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.backup_outlined,
                    title: 'Backup & Restore',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About settings
              _SettingsSection(
                title: 'ABOUT',
                items: [
                  _SettingsItem(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    trailing: Text(
                      _appVersion,
                      style: AppTypography.caption,
                    ),
                    onTap: null,
                  ),
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Logout button
              DangerButton(
                label: 'Log Out',
                icon: Icons.logout,
                fullWidth: true,
                onPressed: () {
                  session.logOut();
                },
              ),
              const SizedBox(height: 16),

              // Version info
              Center(
                child: Text(
                  'HyperLog Ltd. 2025',
                  style: AppTypography.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTypography.label,
          ),
        ),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.borderSubtle,
                      indent: 56,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.denim.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.denimLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.whiteDarker,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subscription tier badge (Standard/Official)
class _SubscriptionBadge extends StatelessWidget {
  final bool isOfficial;

  const _SubscriptionBadge({required this.isOfficial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOfficial
            ? AppColors.endorsedGreen.withValues(alpha: 0.2)
            : AppColors.denim.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isOfficial
              ? AppColors.endorsedGreen.withValues(alpha: 0.4)
              : AppColors.denim.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isOfficial ? 'Official' : 'Standard',
        style: AppTypography.caption.copyWith(
          color: isOfficial ? AppColors.endorsedGreen : AppColors.denimLight,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
