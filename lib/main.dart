import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/neumorphic.dart';
import 'features/analytics/presentation/screens/analytics_screen.dart';
import 'features/limits_and_interventions/presentation/screens/limits_screen.dart';
import 'features/permissions/presentation/screens/permissions_screen.dart';
import 'features/reel_tracker/presentation/controllers/reel_tracker_controller.dart';
import 'features/reel_tracker/presentation/screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ReelsGuardApp(),
    ),
  );
}

class ReelsGuardApp extends StatelessWidget {
  const ReelsGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelsGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RootNavigationShell(),
    );
  }
}

class RootNavigationShell extends StatefulWidget {
  const RootNavigationShell({super.key});

  @override
  State<RootNavigationShell> createState() => _RootNavigationShellState();
}

class _RootNavigationShellState extends State<RootNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    LimitsScreen(),
    PermissionsScreen(),
  ];

  Widget _buildNavItem(int index, String label, IconData icon, IconData activeIcon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: isSelected
            ? NeuTheme.stampedDecoration(
                borderRadius: 14,
                border: Border.all(
                  color: NeuTheme.accentTeal.withValues(alpha: 0.45),
                  width: 1.2,
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? NeuTheme.accentTeal : Colors.white54,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: NeuTheme.baseColor,
            boxShadow: [
              BoxShadow(
                color: NeuTheme.shadowLight.withValues(alpha: 0.45),
                offset: const Offset(0, -3),
                blurRadius: 8,
              ),
              BoxShadow(
                color: NeuTheme.shadowDark.withValues(alpha: 0.8),
                offset: const Offset(0, -1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Tracker', Icons.shield_outlined, Icons.shield),
              _buildNavItem(1, 'Analytics', Icons.insights_outlined, Icons.insights),
              _buildNavItem(2, 'Limits', Icons.tune_outlined, Icons.tune),
              _buildNavItem(3, 'Setup', Icons.verified_user_outlined, Icons.verified_user),
            ],
          ),
        ),
      ),
    );
  }
}
