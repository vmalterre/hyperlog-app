import 'package:flutter/material.dart';
import 'package:hyperlog/config/app_config.dart';
import 'package:hyperlog/theme/app_colors.dart';

/// Displays a banner at the top of the screen when running in dev environment.
/// Wraps child content and only shows the banner when [AppConfig.current.isDev] is true.
class EnvironmentBanner extends StatelessWidget {
  final Widget child;

  const EnvironmentBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.current.isDev) {
      return child;
    }

    return Banner(
      message: 'DEV',
      location: BannerLocation.topEnd,
      color: AppColors.trackedAmber,
      textStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      child: child,
    );
  }
}
