import 'package:flutter/material.dart';

import '../../widgets/placeholder_scaffold.dart';

/// Plan — active diet/condition plan, challenges, recommendations, education.
/// Provider-prescribed plan supersedes elective when linked. EPIC C4.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScaffold(
        title: 'الخطة',
        icon: Icons.restaurant,
        message: 'الخطة النشطة (نظام غذائي أو خطة مرتبطة بحالة) + التحديات + '
            'محرّك التوصيات + المحتوى التثقيفي.\n\nEPIC C4 — docs/PRD.md §6',
      );
}
