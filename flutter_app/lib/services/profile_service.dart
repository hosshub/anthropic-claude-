import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ملف المستخدم المحلي: الاسم المعروض والعمر (اختياريان، على الجهاز فقط).
/// الاسم يغذّي تحية شاشة اليوم بدلاً من مقطع البريد الإلكتروني.
class ProfileService extends ChangeNotifier {
  static const _kDisplayName = 'profile_display_name';
  static const _kAge = 'profile_age';
  static const _kOnboardingDone = 'profile_onboarding_done';

  bool _ready = false;
  String? _displayName;
  int? _age;
  bool _onboardingDone = false;

  ProfileService() {
    _load();
  }

  bool get isReady => _ready;
  String? get displayName => _displayName;
  int? get age => _age;
  bool get hasCompletedOnboarding => _onboardingDone;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_kDisplayName)?.trim();
      _displayName = (name == null || name.isEmpty) ? null : name;
      _age = prefs.getInt(_kAge);
      _onboardingDone = prefs.getBool(_kOnboardingDone) ?? false;
    } catch (_) {
      // قيم افتراضية عند أي عطل في التخزين — لا شيء حرج هنا.
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> setDisplayName(String? name) async {
    final cleaned = name?.trim();
    _displayName = (cleaned == null || cleaned.isEmpty) ? null : cleaned;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_displayName == null) {
        await prefs.remove(_kDisplayName);
      } else {
        await prefs.setString(_kDisplayName, _displayName!);
      }
    } catch (_) {}
  }

  Future<void> setAge(int? age) async {
    _age = (age == null || age < 1 || age > 120) ? null : age;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_age == null) {
        await prefs.remove(_kAge);
      } else {
        await prefs.setInt(_kAge, _age!);
      }
    } catch (_) {}
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboardingDone, true);
    } catch (_) {}
  }

  /// يُستدعى عند حذف الحساب — تنظيف كامل.
  Future<void> reset() async {
    _displayName = null;
    _age = null;
    _onboardingDone = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kDisplayName);
      await prefs.remove(_kAge);
      await prefs.remove(_kOnboardingDone);
    } catch (_) {}
  }
}
