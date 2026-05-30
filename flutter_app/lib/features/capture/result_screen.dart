import 'package:flutter/material.dart';

import '../history/meal_detail_screen.dart';

/// بعد ترقية F2 صارت الوجبة محفوظة محلياً، فنُعيد توجيه شاشة النتيجة
/// إلى شاشة تفاصيل الوجبة المحفوظة (نفس البنية، يدعم متابعة الجسم والحذف).
class ResultScreen extends StatelessWidget {
  final String mealId;
  const ResultScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    return MealDetailScreen(mealId: mealId);
  }
}
