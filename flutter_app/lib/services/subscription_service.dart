import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import 'entitlement.dart';

/// v1.4 — حالة الاشتراك فوق RevenueCat.
///
/// القرارات الخالصة (من مشترك، من مُرقّى قديم، كم تحليلاً بقي) تعيش في
/// entitlement.dart وتُختبر وحدها؛ هذه الطبقة تتولّى المتجر فقط.
///
/// كل شيء دفاعي: غياب مفتاح RevenueCat أو فشل الشبكة يُبقي المستخدم مجانياً
/// دون تعطّل، والخادم يبقى المرجع النهائي للحدّ.
class SubscriptionService extends ChangeNotifier {
  static const String entitlementId = 'premium';
  static const String _kLastSuggestionAt = 'free_last_suggestion_at';

  /// متى أُنشئ حساب المستخدم الحالي. حاقن حتى تستطيع الاختبارات محاكاة
  /// الدخول والخروج بلا Supabase.
  final DateTime? Function() _accountCreatedAt;

  StreamSubscription<AuthState>? _authSub;
  bool _ready = false;
  bool _hasActivePurchase = false;
  Offerings? _offerings;

  /// الاشتراك في تغيّر الجلسة يتم في المُنشئ لا داخل initialize: تسجيل الخروج
  /// يجب أن يُسقط البريميوم حتى لو لم يُهيّأ RevenueCat أصلاً أو فشل تهيئته.
  SubscriptionService({DateTime? Function()? accountCreatedAt})
      : _accountCreatedAt = accountCreatedAt ?? _currentUserCreatedAt {
    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        syncIdentity();
      });
    } catch (_) {
      // Supabase غير مهيّأ (الاختبارات) — الحساب يُقرأ عند الطلب على أي حال.
    }
  }

  bool get isReady => _ready;
  Offerings? get offerings => _offerings;

  /// يُحسب عند القراءة ولا يُخزَّن: أي قيمة محفوظة تخصّ جلسة ربما انتهت.
  /// هذه الخدمة تُنشأ مرة واحدة في جذر التطبيق وتعيش عبر كل دخول وخروج.
  bool get isGrandfatheredUser => isGrandfathered(
        accountCreatedAt: _accountCreatedAt(),
        paidEraCutoff: paidEraCutoffDefault,
      );

  Tier get tier => resolveTier(
        hasActivePurchase: _hasActivePurchase,
        grandfathered: isGrandfatheredUser,
      );

  bool get isPremium => tier == Tier.premium;

  /// هل المتجر متاح فعلاً؟ (بلا مفتاح لا يمكن الشراء.)
  bool get storeAvailable => AppConfig.revenueCatApiKey.isNotEmpty;

  Future<void> initialize() async {
    if (!storeAvailable) {
      _ready = true;
      notifyListeners();
      return;
    }
    try {
      await Purchases.setLogLevel(LogLevel.warn);
      await Purchases.configure(
        PurchasesConfiguration(AppConfig.revenueCatApiKey),
      );
      // اربط هوية RevenueCat بمعرّف Supabase حتى يستطيع webhook تحديث
      // الاستحقاق للمستخدم الصحيح على الخادم.
      final uid = _supabaseUserId();
      if (uid != null) await Purchases.logIn(uid);
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
      await refresh();
    } catch (_) {
      // متجر غير متاح (محاكي، شبكة، إعداد ناقص) — يبقى المستخدم مجانياً.
    }
    _ready = true;
    notifyListeners();
  }

  /// المشترون الأوائل: الحساب أُنشئ قبل التحوّل ⇒ بريميوم مدى الحياة.
  /// الخادم يتحقق من الأمر نفسه في effective_tier، فهذا للعرض فقط.
  static DateTime? _currentUserCreatedAt() {
    try {
      final raw = Supabase.instance.client.auth.currentUser?.createdAt;
      return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
    } catch (_) {
      return null;
    }
  }

  String? _supabaseUserId() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  void _onCustomerInfo(CustomerInfo info) {
    _hasActivePurchase = info.entitlements.active.containsKey(entitlementId);
    notifyListeners();
  }

  /// يعيد قراءة حالة العميل والعروض من RevenueCat.
  Future<void> refresh() async {
    if (!storeAvailable) {
      notifyListeners();
      return;
    }
    try {
      final info = await Purchases.getCustomerInfo();
      _hasActivePurchase = info.entitlements.active.containsKey(entitlementId);
    } catch (_) {}
    try {
      _offerings = await Purchases.getOfferings();
    } catch (_) {}
    notifyListeners();
  }

  /// يشتري باقة. يُعيد نتيجة يمكن للواجهة ترجمتها.
  Future<PurchaseOutcome> purchase(Package package) async {
    if (!storeAvailable) return PurchaseOutcome.unavailable;
    try {
      final result = await Purchases.purchasePackage(package);
      _hasActivePurchase =
          result.entitlements.active.containsKey(entitlementId);
      notifyListeners();
      return _hasActivePurchase
          ? PurchaseOutcome.success
          : PurchaseOutcome.failed;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseOutcome.cancelled;
      }
      return PurchaseOutcome.failed;
    } catch (_) {
      return PurchaseOutcome.failed;
    }
  }

  /// استعادة المشتريات — مطلوبة من مراجعة App Store.
  Future<PurchaseOutcome> restore() async {
    if (!storeAvailable) return PurchaseOutcome.unavailable;
    try {
      final info = await Purchases.restorePurchases();
      _hasActivePurchase = info.entitlements.active.containsKey(entitlementId);
      notifyListeners();
      return _hasActivePurchase
          ? PurchaseOutcome.success
          : PurchaseOutcome.nothingToRestore;
    } catch (_) {
      return PurchaseOutcome.failed;
    }
  }

  // -------------------------------------------------------------------------
  // رصيد الاقتراحات المجاني (أسبوعي)
  // -------------------------------------------------------------------------

  /// هل يستطيع المستخدم طلب اقتراحات الآن؟ المشترك دائماً نعم.
  Future<bool> canRequestSuggestions() async {
    if (isPremium) return true;
    return hasWeeklyAllowance(lastUsedAt: await _lastSuggestionAt(), now: DateTime.now());
  }

  /// يسجّل استهلاك الاقتراح الأسبوعي المجاني (لا أثر للمشترك).
  Future<void> markSuggestionsUsed() async {
    if (isPremium) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _kLastSuggestionAt,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
    notifyListeners();
  }

  Future<DateTime?> _lastSuggestionAt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt(_kLastSuggestionAt);
      return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// يُستدعى بعد تسجيل الدخول/الخروج حتى تتبع هوية RevenueCat المستخدم.
  Future<void> syncIdentity() async {
    if (!storeAvailable) {
      notifyListeners();
      return;
    }
    final uid = _supabaseUserId();
    if (uid == null) {
      // اسقط الشراء قبل النداء لا بعده: لو رمى logOut استثناءً فالمستخدم
      // الخارج يبقى بلا امتيازات بدل أن يحتفظ بها.
      _hasActivePurchase = false;
      try {
        await Purchases.logOut();
      } catch (_) {}
    } else {
      try {
        await Purchases.logIn(uid);
        await refresh();
      } catch (_) {}
    }
    notifyListeners();
  }
}

// ignore_for_file: unnecessary_lambdas

enum PurchaseOutcome {
  success,
  cancelled,
  failed,
  nothingToRestore,
  unavailable,
}
