import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// هدف السعرات اليومي — رقم إرشادي يضبطه المستخدم بنفسه من الإعدادات.
/// لا يقدّم التطبيق أي توصية طبية أو حسابًا للاحتياج؛ القيمة الافتراضية
/// عامة والمستخدم حرّ في تغييرها أو تجاهل العدّاد كليًا.
class NutritionGoalService extends ChangeNotifier {
  static const _key = 'daily_calorie_goal';
  static const defaultGoal = 2000;
  static const minGoal = 800;
  static const maxGoal = 6000;

  int _goal = defaultGoal;
  bool _loaded = false;

  NutritionGoalService() {
    _load();
  }

  int get goal => _goal;
  bool get isLoaded => _loaded;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _goal = (prefs.getInt(_key) ?? defaultGoal).clamp(minGoal, maxGoal);
    } catch (_) {/* نبقى على الافتراضي */}
    _loaded = true;
    notifyListeners();
  }

  Future<void> setGoal(int value) async {
    _goal = value.clamp(minGoal, maxGoal);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, _goal);
    } catch (_) {/* القيمة محفوظة في الذاكرة على الأقل */}
  }
}
