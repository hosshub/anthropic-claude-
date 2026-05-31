import 'package:flutter/material.dart';

import '../meal_banks/meal_banks_screen.dart';

/// ٠٧ — يلفّ MealBanksScreen الفعلي حتى يبقى رابط الفهرس ثابتاً.
class GuideMealBanksWrapper extends StatelessWidget {
  const GuideMealBanksWrapper({super.key});

  @override
  Widget build(BuildContext context) => const MealBanksScreen();
}
