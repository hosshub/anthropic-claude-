import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'health_math.dart';

/// v1.3.0 — تكامل Apple Health (وHealth Connect على أندرويد).
///
/// قراءة: الخطوات، السعرات النشطة، النوم، الوزن.
/// كتابة (اختيارية بموافقة صريحة): سعرات الوجبات المسجَّلة.
///
/// ملاحظة iOS مهمّة: HealthKit لا يكشف حالة إذن القراءة إطلاقاً، فـ
/// [Health.hasPermissions] يُرجع null دائماً لأذونات القراءة على iOS. لذا لا
/// نعتمد عليها كبوابة؛ بل نحفظ أن المستخدم ربَط الحساب ونحاول القراءة مباشرة،
/// ونعرض ما يعود. كل نداء مغلّف بحماية: منصّة غير مدعومة أو إذن مرفوض يعني
/// قيماً فارغة دون تعطّل، والميزة تختفي بهدوء من الواجهة.
class HealthService extends ChangeNotifier {
  static const _kConnected = 'health_connected';
  static const _kWriteMeals = 'health_write_meals';
  static const _kTypesVersion = 'health_types_version';

  /// يزداد كلما أضفنا نوع بيانات جديداً. HealthKit لا يعيد سؤال المستخدم عن
  /// نوع سبق تحديده، فمن ربَط الحساب على نسخة أقدم لن يصله الجديد أبداً ما لم
  /// نطلب الإذن مجدداً — وiOS يعرض حينها الأنواع الجديدة فقط.
  static const int _currentTypesVersion = 2;

  final Health _health = Health();
  bool _configured = false;
  bool _connected = false;
  bool _writeMeals = false;
  int? _steps;
  int? _activeEnergyKcal;
  int? _sleepMinutes;
  double? _weightKg;

  HealthService() {
    _load();
  }

  /// منذ watchOS 9 تكتب ساعة Apple النوم كمراحل (core/deep/REM) ولا تكتب
  /// asleepUnspecified إطلاقاً، والمكوّن يرشّح كل نوع بقيمته الخام. الاكتفاء
  /// بـ SLEEP_ASLEEP يعني صفر دقائق لأغلب المستخدمين، لذا نقرأ المراحل كلها.
  /// جميعها تنتمي لنفس نوع HealthKit، فلا يضيف ذلك صفاً في شاشة الأذونات.
  static const List<HealthDataType> _sleepTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
  ];

  static const List<HealthDataType> _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    ..._sleepTypes,
    HealthDataType.WEIGHT,
  ];
  static const HealthDataType _writeType =
      HealthDataType.DIETARY_ENERGY_CONSUMED;

  /// نطلب الكتابة فقط حين يفعّلها المستخدم، حتى تبقى التجربة قراءة فقط لمن
  /// لا يريد أن يكتب التطبيق شيئاً في ملفه الصحي.
  List<HealthDataType> _types({required bool includeWrite}) => [
        ..._readTypes,
        if (includeWrite) _writeType,
      ];

  List<HealthDataAccess> _perms({required bool includeWrite}) => [
        for (final _ in _readTypes) HealthDataAccess.READ,
        if (includeWrite) HealthDataAccess.WRITE,
      ];

  bool get authorized => _connected;
  bool get writeMealsEnabled => _writeMeals;
  int? get steps => _steps;
  int? get activeEnergyKcal => _activeEnergyKcal;
  int? get sleepMinutes => _sleepMinutes;
  double? get weightKg => _weightKg;

  /// هل توجد بيانات صحية لعرضها؟
  bool get hasData =>
      _connected &&
      (_steps != null ||
          _activeEnergyKcal != null ||
          _sleepMinutes != null ||
          _weightKg != null);

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _connected = prefs.getBool(_kConnected) ?? false;
      _writeMeals = prefs.getBool(_kWriteMeals) ?? false;
      final storedVersion = prefs.getInt(_kTypesVersion) ?? 1;
      if (_connected && storedVersion < _currentTypesVersion) {
        // من ربَط على نسخة أقدم لن يرى النوم والوزن أبداً بلا طلب جديد.
        await _ensureConfigured();
        try {
          await _health.requestAuthorization(
            _types(includeWrite: false),
            permissions: _perms(includeWrite: false),
          );
        } catch (_) {}
        await prefs.setInt(_kTypesVersion, _currentTypesVersion);
      }
    } catch (_) {}
    if (_connected) await _fetch();
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
  Future<bool> connect({bool includeWrite = false}) async {
    await _ensureConfigured();
    assert(
      _types(includeWrite: includeWrite).length ==
          _perms(includeWrite: includeWrite).length,
      'types and permissions must stay the same length',
    );
    try {
      final granted = await _health.requestAuthorization(
        _types(includeWrite: includeWrite),
        permissions: _perms(includeWrite: includeWrite),
      );
      if (!granted) return false;
      _connected = true;
      if (includeWrite) _writeMeals = true;
      await _persistFlags();
      await _fetch();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// يفعّل/يعطّل كتابة سعرات الوجبات. التفعيل يطلب إذن الكتابة من HealthKit.
  Future<bool> setWriteMeals(bool enabled) async {
    if (!enabled) {
      _writeMeals = false;
      await _persistFlags();
      notifyListeners();
      return true;
    }
    await _ensureConfigured();
    try {
      await _health.requestAuthorization(
        _types(includeWrite: true),
        permissions: _perms(includeWrite: true),
      );
      // iOS reports success whenever the request *completes* — including a
      // flat "Don't Allow", and including the case where the type is already
      // determined so no sheet appears. Write access is the one permission
      // HealthKit will actually disclose, so verify it rather than assume.
      final granted = await _health.hasPermissions(
        const [_writeType],
        permissions: const [HealthDataAccess.WRITE],
      );
      if (granted != true) return false;
      _connected = true;
      _writeMeals = true;
      await _persistFlags();
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

  /// يكتب سعرات وجبة في تطبيق الصحة — بهدوء ودون إزعاج المستخدم عند الفشل.
  /// يُتجاهل النداء ما لم يكن الربط والكتابة مفعّلين وللوجبة سعرات فعلية.
  Future<void> writeMealEnergy({
    required int kcal,
    required DateTime at,
  }) async {
    if (!shouldWriteMealEnergy(
      connected: _connected,
      writeEnabled: _writeMeals,
      kcal: kcal,
    )) {
      return;
    }
    await _ensureConfigured();
    try {
      await _health.writeHealthData(
        value: kcal.toDouble(),
        type: _writeType,
        unit: HealthDataUnit.KILOCALORIE,
        startTime: at,
        endTime: at,
        recordingMethod: RecordingMethod.automatic,
      );
    } catch (_) {/* الكتابة إضافة لطيفة، لا تُفشل تسجيل الوجبة */}
  }

  Future<void> _persistFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kConnected, _connected);
      await prefs.setBool(_kWriteMeals, _writeMeals);
      await prefs.setInt(_kTypesVersion, _currentTypesVersion);
    } catch (_) {}
  }

  Future<void> _fetch() async {
    await _ensureConfigured();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    // كل قراءة معزولة: فشل نوع واحد (إذن مرفوض مثلاً) لا يمنع البقية.
    _steps = await _guard(() => _health.getTotalStepsInInterval(midnight, now));
    _activeEnergyKcal = await _guard(() async {
      final points = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: const [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      return _sumNumeric(points).round();
    });
    _sleepMinutes = await _guard(() async {
      // نافذة الليلة: من ظهر أمس حتى الآن، فتلتقط النوم العابر لمنتصف الليل.
      final windowStart = midnight.subtract(const Duration(hours: 12));
      final points = await _health.getHealthDataFromTypes(
        startTime: windowStart,
        endTime: now,
        types: _sleepTypes,
      );
      final minutes = sleepMinutesFromIntervals([
        for (final p in points) (start: p.dateFrom, end: p.dateTo),
      ]);
      // Null (not 0) when nothing was tracked, so the UI hides the metric
      // instead of claiming the user slept zero minutes.
      return minutes == 0 ? null : minutes;
    });
    _weightKg = await _guard(() async {
      final points = await _health.getHealthDataFromTypes(
        startTime: now.subtract(const Duration(days: 60)),
        endTime: now,
        types: const [HealthDataType.WEIGHT],
      );
      return latestSampleValue([
        for (final p in points)
          if (p.value is NumericHealthValue)
            (
              at: p.dateTo,
              value: (p.value as NumericHealthValue).numericValue.toDouble(),
            ),
      ]);
    });
  }

  double _sumNumeric(List<HealthDataPoint> points) {
    var total = 0.0;
    for (final p in points) {
      final v = p.value;
      if (v is NumericHealthValue) total += v.numericValue.toDouble();
    }
    return total;
  }

  Future<T?> _guard<T>(Future<T?> Function() read) async {
    try {
      return await read();
    } catch (_) {
      return null;
    }
  }

  /// عند فصل المستخدم للربط من الإعدادات.
  Future<void> disconnect() async {
    _connected = false;
    _writeMeals = false;
    _steps = null;
    _activeEnergyKcal = null;
    _sleepMinutes = null;
    _weightKg = null;
    notifyListeners();
    await _persistFlags();
  }
}
