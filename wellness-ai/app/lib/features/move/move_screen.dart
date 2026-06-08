import 'package:flutter/material.dart';

import '../../widgets/placeholder_scaffold.dart';

/// Move — activity/exercise, wearable data, recommended workouts.
/// Wearables via aggregator (Terra/Spike) in Phase 2. EPIC C5.
class MoveScreen extends StatelessWidget {
  const MoveScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScaffold(
        title: 'النشاط',
        icon: Icons.directions_run,
        message: 'النشاط والتمارين + بيانات الأجهزة القابلة للارتداء + تمارين '
            'مقترحة حسب الخطة.\n\nEPIC C5 — docs/PRD.md §6, §9',
      );
}
