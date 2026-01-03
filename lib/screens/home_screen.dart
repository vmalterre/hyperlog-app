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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const LogbookScreen(),
      const StatisticsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.nightRider,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: screens[_selectedIndex],
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
