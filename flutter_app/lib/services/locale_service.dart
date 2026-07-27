import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تبديل اللغة في وقت التشغيل بين العربية والإنجليزية.
/// المستخدم يبدّل من الإعدادات؛ MaterialApp يعيد البناء فوراً.
class LocaleService extends ChangeNotifier {
  static const String _prefsKey = 'app_locale';
  static const Locale _arabic = Locale('ar');
  static const Locale _english = Locale('en');

  Locale _locale = _arabic;
  bool _ready = false;

  LocaleService() {
    _load();
  }

  Locale get locale => _locale;
  bool get isReady => _ready;
  bool get isArabic => _locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == 'en') _locale = _english;
    _ready = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale value) async {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, value.languageCode);
  }

  Future<void> setArabic() => setLocale(_arabic);
  Future<void> setEnglish() => setLocale(_english);
}
