// v1.4 — قرارات الاشتراك الخالصة (بلا StoreKit) حتى تكون قابلة للاختبار.

/// مستوى المستخدم.
enum Tier { free, premium }

/// عدد تحليلات الذكاء الاصطناعي المجانية أسبوعياً.
/// كل ما عداه (بنك الطعام، الدليل، السجل، تطبيق الصحة…) مجاني بلا حدود،
/// لأن تكلفته الحدّية صفر — التحليل وحده هو ما يُقاس.
const int freeScansPerWeek = 3;

/// اللحظة التي تحوّل عندها التطبيق من مدفوع إلى مجاني.
///
/// التطبيق كان مدفوعاً **ويشترط حساباً**، لذا كل حساب أُنشئ قبل هذا التاريخ
/// يخصّ مستخدماً دفع ثمن التطبيق فعلاً — فيحصل على المزايا الكاملة مدى الحياة.
/// حدِّث هذا التاريخ ليطابق تاريخ إصدار 1.4 الفعلي قبل النشر.
final DateTime paidEraCutoffDefault = DateTime.utc(2026, 8, 1);

/// هل يستحق المستخدم الترقية المجانية الدائمة (اشترى النسخة المدفوعة)؟
bool isGrandfathered({
  required DateTime? accountCreatedAt,
  required DateTime paidEraCutoff,
}) {
  if (accountCreatedAt == null) return false;
  return accountCreatedAt.isBefore(paidEraCutoff);
}

Tier resolveTier({
  required bool hasActivePurchase,
  required bool grandfathered,
}) =>
    (hasActivePurchase || grandfathered) ? Tier.premium : Tier.free;

/// بداية أسبوع التطبيق (السبت) — يطابق التقويم والتحضير الأسبوعي.
DateTime weekStart(DateTime now) {
  final d = DateTime(now.year, now.month, now.day);
  // DateTime.saturday == 6؛ نرجع للخلف حتى أقرب سبت.
  final daysSinceSaturday = (d.weekday - DateTime.saturday + 7) % 7;
  return DateTime(d.year, d.month, d.day - daysSinceSaturday);
}

/// كم تحليلاً بقي هذا الأسبوع؟ null تعني بلا حدود (مشترك).
int? scansRemainingThisWeek({
  required Tier tier,
  required Iterable<DateTime> scanTimes,
  required DateTime now,
}) {
  if (tier == Tier.premium) return null;
  final start = weekStart(now);
  final used = scanTimes.where((t) => !t.isBefore(start)).length;
  final left = freeScansPerWeek - used;
  return left < 0 ? 0 : left;
}

/// null (مشترك) أو رصيد متبقٍ أكبر من صفر.
bool canScan({required int? remaining}) => remaining == null || remaining > 0;
