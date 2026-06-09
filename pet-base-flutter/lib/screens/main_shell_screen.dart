import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'notification_settings_screen.dart';
import 'pet_profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;
  final _screens = const [DashboardScreen(), HistoryScreen(), PetProfileScreen(), NotificationSettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const PetLogo(size: 34),
        actions: const [BellDot(), SizedBox(width: 8)],
      ),
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _index,
        indicatorColor: AppColors.brandSoft,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '홈'),
          NavigationDestination(icon: Icon(Icons.query_stats_rounded), label: '기록'),
          NavigationDestination(icon: Icon(Icons.pets_rounded), label: '반려견'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: '설정'),
        ],
      ),
    );
  }
}
