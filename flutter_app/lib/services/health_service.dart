import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// v1.3.0 — قراءة الخطوات والسعرات المحروقة من Apple Health (وHealth Connect
/// على أندرويد). قراءة فقط. كل شيء مغلّف بحماية: أي فشل أو منصّة غير مدعومة
/// تعني قيم null دون تعطّل، والميزة تختفي بهدوء من الواجهة.
///
/// ملاحظة iOS مهمّة: HealthKit لا يكشف حالة إذن القراءة إطلاقاً، فـ
/// [Health.hasPermissions] يُرجع null دائماً لأذونات القراءة على iOS. لذا لا
/// نعتمد عليها كبوابة؛ بل نحفظ أن المستخدم ربَط الحساب ونحاول القراءة مباشرة،
/// ونعرض ما يعود (قد يكون صفراً إن رفض المستخدم في حوار الصحة).
class HealthService extends ChangeNotifier {
  static const _kConnected = 'health_connected';

  final Health _health = Health();
  bool _configured = false;
  bool _connected = false;
  int? _steps;
  int? _activeEnergyKcal;

  HealthService() {
    _load();
  }

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];
  static const List<HealthDataAccess> _perms = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// هل ربَط المستخدم Apple Health؟ (مصدر الحقيقة للعرض والمقاصّة.)
  bool get authorized => _connected;
  int? get steps => _steps;
  int? get activeEnergyKcal => _activeEnergyKcal;

  /// هل توجد بيانات صحية لعرضها؟
  bool get hasData =>
      _connected && (_steps != null || _activeEnergyKcal != null);

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _connected = prefs.getBool(_kConnected) ?? false;
    } catch (_) {}
    if (_connected) await refresh();
    notifyListeners();
  }

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    try {
      await _health.configure();
      _configured = true;
    } catch (_) {/* منصّة غير مدعومة */}
  }

  /// يطلب الإذن مرة واحدة ثم يجلب بيانات اليوم. يُستدعى من زر الربط.
  Future<bool> connect() async {
    await _ensureConfigured();
    try {
      final granted =
          await _health.requestAuthorization(_types, permissions: _perms);
      if (!granted) return false;
      _connected = true;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kConnected, true);
      } catch (_) {}
      await _fetch();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// يجلب بيانات اليوم إن كان المستخدم قد ربَط الحساب. لا يطلب إذناً جديداً
  /// ولا يعتمد على hasPermissions (التي تُرجع null على iOS للقراءة).
  Future<void> refresh() async {
    if (!_connected) return;
    await _fetch();
    notifyListeners();
  }

  Future<void> _fetch() async {
    await _ensureConfigured();
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      _steps = await _health.getTotalStepsInInterval(midnight, now);
      final points = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: const [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      var kcal = 0.0;
      for (final p in points) {
        final v = p.value;
        if (v is NumericHealthValue) kcal += v.numericValue.toDouble();
      }
      _activeEnergyKcal = kcal.round();
    } catch (_) {/* اترك القيم كما هي */}
  }

  /// عند فصل المستخدم للربط من الإعدادات.
  Future<void> disconnect() async {
    _connected = false;
    _steps = null;
    _activeEnergyKcal = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kConnected, false);
    } catch (_) {}
  }
}
