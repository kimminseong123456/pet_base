import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/pet_profile_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const PetBaseApp());
}

class PetBaseApp extends StatelessWidget {
  const PetBaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PET BASE',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.brand,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: null,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              color: selected ? AppColors.brand : AppColors.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.brand : AppColors.textSecondary,
              size: selected ? 30 : 28,
            );
          }),
        ),
      ),
      home: const PetBaseHome(),
    );
  }
}

class PetBaseHome extends StatefulWidget {
  const PetBaseHome({super.key});

  @override
  State<PetBaseHome> createState() => _PetBaseHomeState();
}

class _PetBaseHomeState extends State<PetBaseHome> {
  int _index = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    PetProfileScreen(),
    NotificationSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.7))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: NavigationBar(
          height: 74,
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: '홈'),
            NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: '기록'),
            NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets_rounded), label: '반려견'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: '설정'),
          ],
        ),
      ),
    );
  }
}
