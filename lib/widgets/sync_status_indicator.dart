import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyperlog/database/database_provider.dart';
import 'package:hyperlog/services/sync_service.dart';
import 'package:hyperlog/theme/app_colors.dart';

/// Displays a subtle indicator showing offline/sync status.
///
/// Shows:
/// - Nothing when online and synced (normal state)
/// - Cloud-off icon when offline
/// - Sync icon when syncing
/// - Warning when there are pending changes
class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  StreamSubscription<SyncStatus>? _syncSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  SyncStatus _syncStatus = SyncStatus.idle;
  bool _isOnline = true;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _syncSubscription = syncService.statusStream.listen((status) {
      if (mounted) {
        setState(() => _syncStatus = status);
        if (status == SyncStatus.syncing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });

    _connectivitySubscription = connectivity.onlineStream.listen((online) {
      if (mounted) {
        setState(() => _isOnline = online);
      }
    });
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything when online and idle (normal state)
    if (_isOnline && _syncStatus == SyncStatus.idle) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 12,
              color: _getTextColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (!_isOnline) {
      return Icon(
        Icons.cloud_off,
        size: 14,
        color: _getTextColor(),
      );
    }

    if (_syncStatus == SyncStatus.syncing) {
      return RotationTransition(
        turns: _rotationController,
        child: Icon(
          Icons.sync,
          size: 14,
          color: _getTextColor(),
        ),
      );
    }

    if (_syncStatus == SyncStatus.error) {
      return Icon(
        Icons.warning_amber_rounded,
        size: 14,
        color: _getTextColor(),
      );
    }

    return const SizedBox.shrink();
  }

  Color _getBackgroundColor() {
    if (!_isOnline) {
      return AppColors.nightRiderLight;
    }
    if (_syncStatus == SyncStatus.syncing) {
      return AppColors.denim.withOpacity(0.2);
    }
    if (_syncStatus == SyncStatus.error) {
      return Colors.orange.withOpacity(0.2);
    }
    return Colors.transparent;
  }

  Color _getTextColor() {
    if (!_isOnline) {
      return AppColors.whiteDarker;
    }
    if (_syncStatus == SyncStatus.syncing) {
      return AppColors.denimLight;
    }
    if (_syncStatus == SyncStatus.error) {
      return Colors.orange;
    }
    return AppColors.white;
  }

  String _getStatusText() {
    if (!_isOnline) {
      return 'Offline';
    }
    switch (_syncStatus) {
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.error:
        return 'Sync failed';
      default:
        return '';
    }
  }
}

/// A more compact version for use in app bars
class SyncStatusIcon extends StatefulWidget {
  const SyncStatusIcon({super.key});

  @override
  State<SyncStatusIcon> createState() => _SyncStatusIconState();
}

class _SyncStatusIconState extends State<SyncStatusIcon>
    with SingleTickerProviderStateMixin {
  StreamSubscription<SyncStatus>? _syncSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  SyncStatus _syncStatus = SyncStatus.idle;
  bool _isOnline = true;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _syncSubscription = syncService.statusStream.listen((status) {
      if (mounted) {
        setState(() => _syncStatus = status);
        if (status == SyncStatus.syncing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });

    _connectivitySubscription = connectivity.onlineStream.listen((online) {
      if (mounted) {
        setState(() => _isOnline = online);
      }
    });
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything when online and idle
    if (_isOnline && _syncStatus == SyncStatus.idle) {
      return const SizedBox.shrink();
    }

    if (!_isOnline) {
      return Tooltip(
        message: 'Offline - changes will sync when connected',
        child: Icon(
          Icons.cloud_off,
          size: 18,
          color: AppColors.whiteDarker,
        ),
      );
    }

    if (_syncStatus == SyncStatus.syncing) {
      return Tooltip(
        message: 'Syncing...',
        child: RotationTransition(
          turns: _rotationController,
          child: Icon(
            Icons.sync,
            size: 18,
            color: AppColors.denimLight,
          ),
        ),
      );
    }

    if (_syncStatus == SyncStatus.error) {
      return Tooltip(
        message: 'Sync failed - tap to retry',
        child: GestureDetector(
          onTap: () => syncService.syncNow(),
          child: Icon(
            Icons.sync_problem,
            size: 18,
            color: Colors.orange,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
