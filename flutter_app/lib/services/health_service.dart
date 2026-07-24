import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// v1.3.0 — قراءة الخطوات والسعرات المحروقة من Apple Health (وHealth Connect
/// على أندرويد). قراءة فقط. كل شيء مغلّف بحماية: أي فشل أو منصّة غير مدعومة
/// تعني قيم null دون تعطّل، والميزة تختفي بهدوء من الواجهة.
class HealthService extends ChangeNotifier {
  final Health _health = Health();
  bool _configured = false;
  bool _authorized = false;
  int? _steps;
  int? _activeEnergyKcal;

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];
  static const List<HealthDataAccess> _perms = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  bool get authorized => _authorized;
  int? get steps => _steps;
  int? get activeEnergyKcal => _activeEnergyKcal;

  /// هل توجد بيانات صحية لعرضها (مصرّح ومتوفّرة)؟
  bool get hasData => _authorized && (_steps != null || _activeEnergyKcal != null);

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
      _authorized = granted;
      if (granted) await refresh();
      notifyListeners();
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// يجلب خطوات وسعرات اليوم إن كان الإذن ممنوحاً — بلا طلب إذن جديد.
  /// يُستدعى عند فتح شاشة اليوم لتحديث الأرقام.
  Future<void> refresh() async {
    await _ensureConfigured();
    try {
      final has =
          await _health.hasPermissions(_types, permissions: _perms) ?? false;
      _authorized = has;
      if (!has) {
        notifyListeners();
        return;
      }
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
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  /// عند فصل المستخدم للربط من الإعدادات — ننسى القيم محلياً.
  void disconnect() {
    _authorized = false;
    _steps = null;
    _activeEnergyKcal = null;
    notifyListeners();
  }
}
