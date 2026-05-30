import 'package:flutter/material.dart';

import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_screen.dart';
import '../theme/theme.dart';

/// إطار التطبيق الرئيسي بعد تسجيل الدخول — شريط تبويب سفلي بثلاث تبويبات.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // IndexedStack يحافظ على حالة كل تبويب (مثلاً قائمة السجل لا تُعاد بناءها كل مرة).
  final _screens = const [
    TodayScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: TColors.primary.withOpacity(0.15),
        backgroundColor: TColors.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny, color: TColors.primary),
            label: 'اليوم',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: TColors.primary),
            label: 'السجل',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: TColors.primary),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
