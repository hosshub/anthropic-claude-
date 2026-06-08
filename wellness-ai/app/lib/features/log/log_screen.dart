import 'package:flutter/material.dart';

import '../../widgets/placeholder_scaffold.dart';

/// Log / History — meals list + monthly calendar + Wellness Intelligence
/// (trends, streaks, body-response). See docs/PRD.md EPIC C3.
class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScaffold(
        title: 'السجل',
        icon: Icons.menu_book,
        message: 'قائمة الوجبات + تقويم شهري + ذكاء العافية (الاتجاهات، '
            'السلاسل، استجابة الجسم).\n\nEPIC C3 — docs/PRD.md §6',
      );
}
