import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:hyperlog/session_state.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/glass_card.dart';
import 'package:hyperlog/widgets/app_button.dart';
import '../constants/airport_format.dart';
import '../services/preferences_service.dart';
import 'display_options_screen.dart';
import 'saved_pilots_screen.dart';
import 'my_roles_screen.dart';
import 'my_aircraft_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  AirportCodeFormat _airportCodeFormat = AirportCodeFormat.iata;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadPreferences();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  void _loadPreferences() {
    setState(() {
      _airportCodeFormat = PreferencesService.instance.getAirportCodeFormat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionState>(context);
    final pilot = session.currentPilot;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Settings', style: AppTypography.h2(context)),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your account',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _TierBadge(isOfficial: isOfficial),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Identity Card
              _PilotIdentityCard(
                displayName: displayName,
                email: email,
                photoUrl: photoUrl,
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

              // Logbook settings
              _SettingsSection(
                title: 'LOGBOOK',
                items: [
                  _SettingsItem(
                    icon: Icons.tune,
                    title: 'Display Options',
                    subtitle: '${AirportFormats.getDisplayName(_airportCodeFormat)} codes',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DisplayOptionsScreen(),
                        ),
                      );
                      _loadPreferences();
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.badge_outlined,
                    title: 'My Roles',
                    subtitle: 'Default role for new flights',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyRolesScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.people_outline,
                    title: 'My Pilots',
                    subtitle: 'Manage saved crew members',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedPilotsScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.flight,
                    title: 'My Aircrafts',
                    subtitle: 'Manage aircraft types and registrations',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyAircraftScreen(),
                        ),
                      );
                    },
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

/// Pilot Identity Card - Clean design
class _PilotIdentityCard extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoUrl;

  const _PilotIdentityCard({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(width: 16),
          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: AppTypography.h4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Chevron
          Icon(
            Icons.chevron_right,
            color: AppColors.whiteDarker,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.denim.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.nightRiderDark,
          borderRadius: BorderRadius.circular(11.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: photoUrl != null
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 28,
                  color: AppColors.denimLight,
                ),
              )
            : const Icon(
                Icons.person,
                size: 28,
                color: AppColors.denimLight,
              ),
      ),
    );
  }
}

/// Premium tier badge - Standard vs Official
class _TierBadge extends StatelessWidget {
  final bool isOfficial;

  const _TierBadge({required this.isOfficial});

  @override
  Widget build(BuildContext context) {
    if (isOfficial) {
      // Premium Official badge with gradient and icon
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.denim,
              AppColors.denimLight,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.denim.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 18,
              color: AppColors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'OFFICIAL',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      );
    }

    // Standard badge - simpler style
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.nightRiderLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.whiteDarker.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'STANDARD',
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.whiteDarker,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
