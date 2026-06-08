import 'package:flutter/material.dart';

import '../features/guide/guide_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/theme.dart';

/// إطار التطبيق بعد تسجيل الدخول — شريط تبويب سفلي بأربع تبويبات.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    TodayScreen(),
    HistoryScreen(),
    GuideScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: TColors.primary.withOpacity(0.15),
        backgroundColor: TColors.surface,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny, color: TColors.primary),
            label: l.tab_today,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon:
                const Icon(Icons.calendar_today, color: TColors.primary),
            label: l.tab_history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book, color: TColors.primary),
            label: l.tab_guide,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings, color: TColors.primary),
            label: l.tab_settings,
          ),
        ],
      ),
    );
  }
}
