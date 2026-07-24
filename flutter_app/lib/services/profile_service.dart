import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ملف المستخدم المحلي: الاسم الأول والأخير واللقب والعمر (كلها اختيارية،
/// على الجهاز فقط). التحية تفضّل اللقب ثم الاسم الأول.
class ProfileService extends ChangeNotifier {
  static const _kFirstName = 'profile_first_name';
  static const _kLastName = 'profile_last_name';
  static const _kNickname = 'profile_nickname';
  static const _kAge = 'profile_age';
  static const _kOnboardingDone = 'profile_onboarding_done';
  // v1.2 مفتاح قديم — يُهاجَر إلى الاسم الأول.
  static const _kLegacyDisplayName = 'profile_display_name';

  bool _ready = false;
  String? _firstName;
  String? _lastName;
  String? _nickname;
  int? _age;
  bool _onboardingDone = false;

  ProfileService() {
    _load();
  }

  bool get isReady => _ready;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get nickname => _nickname;
  int? get age => _age;
  bool get hasCompletedOnboarding => _onboardingDone;

  /// الاسم المعروض في التحية: اللقب إن وُجد، وإلا الاسم الأول، وإلا لا شيء.
  String? get greetingName => _nickname ?? _firstName;

  /// اسم كامل للعرض حيثما يلزم اسم واحد (اللقب أو الاسم الأول+الأخير).
  String? get displayName {
    if (_nickname != null) return _nickname;
    final full = [_firstName, _lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ')
        .trim();
    return full.isEmpty ? null : full;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _firstName = _clean(prefs.getString(_kFirstName));
      _lastName = _clean(prefs.getString(_kLastName));
      _nickname = _clean(prefs.getString(_kNickname));
      _age = prefs.getInt(_kAge);
      _onboardingDone = prefs.getBool(_kOnboardingDone) ?? false;

      // ترحيل الاسم القديم (v1.2) إلى الاسم الأول لمرّة واحدة.
      final legacy = _clean(prefs.getString(_kLegacyDisplayName));
      if (legacy != null && _firstName == null) {
        _firstName = legacy;
        await prefs.setString(_kFirstName, legacy);
        await prefs.remove(_kLegacyDisplayName);
      }
    } catch (_) {
      // قيم افتراضية عند أي عطل — لا شيء حرج.
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> setFirstName(String? v) =>
      _setString(_kFirstName, v, (c) => _firstName = c);

  Future<void> setLastName(String? v) =>
      _setString(_kLastName, v, (c) => _lastName = c);

  Future<void> setNickname(String? v) =>
      _setString(_kNickname, v, (c) => _nickname = c);

  Future<void> _setString(
    String key,
    String? value,
    void Function(String?) assign,
  ) async {
    final cleaned = _clean(value);
    assign(cleaned);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (cleaned == null) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, cleaned);
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
    _firstName = null;
    _lastName = null;
    _nickname = null;
    _age = null;
    _onboardingDone = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final k in [
        _kFirstName,
        _kLastName,
        _kNickname,
        _kAge,
        _kOnboardingDone,
        _kLegacyDisplayName,
      ]) {
        await prefs.remove(k);
      }
    } catch (_) {}
  }

  String? _clean(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
