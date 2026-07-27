import 'package:flutter/material.dart';

import '../history/meal_detail_screen.dart';

/// Post-analysis result. Renders the same MealDetailScreen body but flagged
/// so the chrome adapts — close-X leading icon, sticky bottom action bar
/// (Done + Capture another + Log how you felt), no delete button.
class ResultScreen extends StatelessWidget {
  final String mealId;
  const ResultScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    return MealDetailScreen(mealId: mealId, isPostCapture: true);
  }
}
