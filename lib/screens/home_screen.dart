import 'package:flutter/material.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/screens/settings_screen.dart';
import 'package:hyperlog/screens/logbook_screen.dart';
import 'package:hyperlog/screens/statistics_screen.dart';
import 'package:hyperlog/widgets/glass_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _logbookKey = GlobalKey<LogbookScreenState>();

  void _onItemTapped(int index) {
    final previousIndex = _selectedIndex;
    setState(() {
      _selectedIndex = index;
    });
    // Notify logbook screen when it becomes visible (returning from settings)
    if (index == 0 && previousIndex != 0) {
      // Use post-frame callback to ensure the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logbookKey.currentState?.onBecameVisible();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      extendBody: true,
      extendBodyBehindAppBar: true,
      // Use IndexedStack to keep all tabs alive (preserves state when switching)
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          LogbookScreen(key: _logbookKey),
          const StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          GlassBottomNavItem(
            icon: Icons.book_outlined,
            activeIcon: Icons.book,
            label: 'Logbook',
          ),
          GlassBottomNavItem(
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
            label: 'Stats',
          ),
          GlassBottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
