import 'dart:math';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/tips_data.dart';

/// أنواع الإشعارات. كل نوع له معرف رقمي ثابت وتوقيت افتراضي.
enum NotifKind { morningTip, lunchReminder, eveningTip, endOfDayLog, weeklyPrep }

extension NotifKindMeta on NotifKind {
  int get id {
    switch (this) {
      case NotifKind.morningTip:
        return 1001;
      case NotifKind.lunchReminder:
        return 1002;
      case NotifKind.eveningTip:
        return 1003;
      case NotifKind.endOfDayLog:
        return 1004;
      case NotifKind.weeklyPrep:
        return 1005;
    }
  }

  /// Title used on the notification + Android channel name. Reads the user's
  /// chosen app language so reminders match the in-app language.
  String label(String locale) {
    if (locale == 'en') {
      switch (this) {
        case NotifKind.morningTip:
          return 'Morning tip';
        case NotifKind.lunchReminder:
          return 'Lunch reminder';
        case NotifKind.eveningTip:
          return 'Evening tip';
        case NotifKind.endOfDayLog:
          return 'Log your meals';
        case NotifKind.weeklyPrep:
          return 'Weekly prep';
      }
    }
    switch (this) {
      case NotifKind.morningTip:
        return 'نصيحة الصباح';
      case NotifKind.lunchReminder:
        return 'تذكير الغداء';
      case NotifKind.eveningTip:
        return 'نصيحة المساء';
      case NotifKind.endOfDayLog:
        return 'سجّل وجباتك';
      case NotifKind.weeklyPrep:
        return 'تحضير الأسبوع';
    }
  }

  /// Android channel description + fallback body when no tip is available.
  String description(String locale) {
    if (locale == 'en') {
      switch (this) {
        case NotifKind.morningTip:
          return 'A morning tip from the Tayyibat system.';
        case NotifKind.lunchReminder:
          return 'A lunchtime reminder with a daily golden rule.';
        case NotifKind.eveningTip:
          return 'An evening tip before dinner.';
        case NotifKind.endOfDayLog:
          return 'Reminder to log what you ate today.';
        case NotifKind.weeklyPrep:
          return 'Every Saturday morning — a weekly prep checklist.';
      }
    }
    switch (this) {
      case NotifKind.morningTip:
        return 'تذكير صباحي بنصيحة من نظام الطيبات.';
      case NotifKind.lunchReminder:
        return 'تذكير بوقت الغداء وقاعدة ذهبية تختلف يومياً.';
      case NotifKind.eveningTip:
        return 'نصيحة المساء قبل العشاء.';
      case NotifKind.endOfDayLog:
        return 'تذكير بتسجيل ما أكلت اليوم.';
      case NotifKind.weeklyPrep:
        return 'كل سبت صباحاً — قائمة تحضير الأسبوع.';
    }
  }

  /// الوقت الافتراضي (٢٤ ساعة).
  /// الإشعار الأسبوعي يستخدم weekday=6 (السبت) بالإضافة للوقت.
  (int hour, int minute) get defaultTime {
    switch (this) {
      case NotifKind.morningTip:
        return (8, 0);
      case NotifKind.lunchReminder:
        return (13, 0);
      case NotifKind.eveningTip:
        return (18, 0);
      case NotifKind.endOfDayLog:
        return (21, 30);
      case NotifKind.weeklyPrep:
        return (8, 0);
    }
  }

  TipSlot get tipSlot {
    switch (this) {
      case NotifKind.morningTip:
        return TipSlot.morning;
      case NotifKind.lunchReminder:
        return TipSlot.afternoon;
      case NotifKind.eveningTip:
        return TipSlot.evening;
      case NotifKind.endOfDayLog:
        return TipSlot.general;
      case NotifKind.weeklyPrep:
        return TipSlot.prep;
    }
  }
}

/// خدمة الإشعارات المحلية. تشتغل كـ ChangeNotifier حتى تعيد شاشة الإعدادات
/// رسم نفسها فور تغير الجلسة (تشغيل/إيقاف). تختار نصيحة جديدة عند كل جدولة
/// مع تجنّب آخر ١٠ نصائح ظهرت لكل تصنيف.
class NotificationService extends ChangeNotifier {
  static const String _kEnabled = 'notif_enabled_';
  static const String _kRecent = 'notif_recent_'; // ذيل آخر النصائح لكل تصنيف
  static const String _kBodyFollowupEnabled = 'notif_body_followup_enabled';
  static const String _kBodyFollowupIds = 'notif_body_followup_ids';
  static const Duration _bodyFollowupDelay = Duration(hours: 3);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Random _rng = Random();

  bool _ready = false;
  bool _permissionGranted = false;
  final Map<NotifKind, bool> _enabled = {};
  bool _bodyFollowupEnabled = true;

  bool get isReady => _ready;
  bool get bodyFollowupEnabled => _bodyFollowupEnabled;
  bool get permissionGranted => _permissionGranted;
  bool enabled(NotifKind k) => _enabled[k] ?? false;

  /// تشغيل النوع جميعاً معاً.
  bool get anyEnabled => _enabled.values.any((v) => v);

  Future<void> initialize() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    _setLocalTimezoneBestEffort();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(initSettings);

    final prefs = await SharedPreferences.getInstance();
    for (final k in NotifKind.values) {
      _enabled[k] = prefs.getBool('$_kEnabled${k.name}') ?? false;
    }
    // Body-followup is opt-in but defaults to true on first launch.
    _bodyFollowupEnabled = prefs.getBool(_kBodyFollowupEnabled) ?? true;
    _permissionGranted = await _checkPermission();
    _ready = true;
    notifyListeners();
  }

  void _setLocalTimezoneBestEffort() {
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    String name;
    switch (offsetHours) {
      case 2:
        name = 'Africa/Cairo';
        break;
      case 3:
        name = 'Asia/Riyadh';
        break;
      case 4:
        name = 'Asia/Dubai';
        break;
      default:
        // Etc/GMT signs are inverted from the offset.
        name = offsetHours >= 0
            ? 'Etc/GMT-$offsetHours'
            : 'Etc/GMT+${offsetHours.abs()}';
    }
    try {
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// يطلب الإذن من النظام (مرة واحدة). يرجع true إن أعطاه المستخدم.
  Future<bool> requestPermission() async {
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      _permissionGranted = granted ?? false;
    }
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      _permissionGranted = granted ?? _permissionGranted;
    }
    notifyListeners();
    return _permissionGranted;
  }

  Future<bool> _checkPermission() async {
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final perm = await iosPlugin.checkPermissions();
      if (perm != null) return perm.isEnabled;
    }
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      return enabled ?? false;
    }
    return false;
  }

  /// شغّل/أوقف نوعاً واحداً. يحفظ التفضيل ويعيد جدولة الإشعار.
  Future<void> setEnabled(NotifKind kind, bool on) async {
    _enabled[kind] = on;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kEnabled${kind.name}', on);
    if (on) {
      if (!_permissionGranted) {
        await requestPermission();
      }
      await _schedule(kind);
    } else {
      await _plugin.cancel(kind.id);
    }
    notifyListeners();
  }

  Future<String> _currentLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('app_locale') == 'en' ? 'en' : 'ar';
    } catch (_) {
      return 'ar';
    }
  }

  Future<void> _schedule(NotifKind kind) async {
    final (h, m) = kind.defaultTime;
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
    if (when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }
    // إشعار التحضير: انتقل لأقرب سبت في الموعد.
    if (kind == NotifKind.weeklyPrep) {
      while (when.weekday != DateTime.saturday) {
        when = when.add(const Duration(days: 1));
      }
    }

    final locale = await _currentLocale();
    final tip = await _pickTip(kind.tipSlot);
    final body = tip?.text(locale) ?? kind.description(locale);
    final title = kind.label(locale);

    await _plugin.zonedSchedule(
      kind.id,
      title,
      body,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'tayyibat_${kind.name}',
          title,
          channelDescription: kind.description(locale),
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          // White-silhouette resource on Android. Without this Android
          // renders a generic white square in the status bar. The PNG
          // lives in android/app/src/main/res/drawable/ic_notification.png
          // (see submission/android-shell.md step 4).
          icon: '@drawable/ic_notification',
          color: Color(0xFFC9A35B), // gold tint for the icon dot
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: kind == NotifKind.weeklyPrep
          ? DateTimeComponents.dayOfWeekAndTime
          : DateTimeComponents.time,
    );
  }

  /// يختار نصيحة لم تظهر في آخر ١٠ مرات (لكل تصنيف).
  Future<Tip?> _pickTip(TipSlot slot) async {
    final pool = TipsData.bySlot(slot);
    if (pool.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('$_kRecent${slot.name}') ?? const [];
    final fresh = pool.where((t) => !recent.contains(t.id)).toList();
    final pick = fresh.isNotEmpty
        ? fresh[_rng.nextInt(fresh.length)]
        : pool[_rng.nextInt(pool.length)];
    final newRecent = [...recent, pick.id];
    while (newRecent.length > 10) {
      newRecent.removeAt(0);
    }
    await prefs.setStringList('$_kRecent${slot.name}', newRecent);
    return pick;
  }

  /// إلغاء كل ما هو مجدول (يفيد عند تسجيل الخروج).
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // Body-response followup — one-shot reminder ~3h after each meal.
  // ---------------------------------------------------------------------------

  Future<void> setBodyFollowupEnabled(bool on) async {
    _bodyFollowupEnabled = on;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBodyFollowupEnabled, on);
    if (!on) {
      await cancelAllBodyFollowups();
    }
    notifyListeners();
  }

  int _bodyFollowupId(String mealId) =>
      (mealId.hashCode & 0x7FFFFFFF) % 100000000 + 10000;

  /// Schedule a one-shot "how did you feel?" nudge ~3 hours after the meal.
  /// Silently no-ops if the feature is off, permission isn't granted, or the
  /// meal was captured long enough ago that the scheduled time is already past.
  Future<void> scheduleBodyFollowup(
    String mealId,
    DateTime capturedAt, {
    Duration? delay,
  }) async {
    if (!_ready) await initialize();
    if (!_bodyFollowupEnabled || !_permissionGranted) return;

    final fireAt = capturedAt.add(delay ?? _bodyFollowupDelay);
    final now = DateTime.now();
    if (fireAt.isBefore(now.add(const Duration(seconds: 30)))) return;

    final locale = await _currentLocale();
    final timeLabel = _formatTime(capturedAt);
    final (title, body) = _bodyFollowupCopy(locale, timeLabel);

    final tzWhen = tz.TZDateTime.from(fireAt, tz.local);
    final id = _bodyFollowupId(mealId);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzWhen,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tayyibat_body_followup',
          'Body response',
          channelDescription: 'How did you feel after the meal?',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@drawable/ic_notification',
          color: Color(0xFFC9A35B),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'body-response:$mealId',
    );

    await _rememberFollowup(mealId);
  }

  Future<void> cancelBodyFollowup(String mealId) async {
    await _plugin.cancel(_bodyFollowupId(mealId));
    await _forgetFollowup(mealId);
  }

  Future<void> cancelAllBodyFollowups() async {
    final ids = await _loadFollowupIds();
    for (final mealId in ids) {
      await _plugin.cancel(_bodyFollowupId(mealId));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBodyFollowupIds);
  }

  Future<List<String>> _loadFollowupIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kBodyFollowupIds) ?? const [];
  }

  Future<void> _rememberFollowup(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = (prefs.getStringList(_kBodyFollowupIds) ?? const <String>[]).toList();
    if (!list.contains(mealId)) {
      list.add(mealId);
      await prefs.setStringList(_kBodyFollowupIds, list);
    }
  }

  Future<void> _forgetFollowup(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = (prefs.getStringList(_kBodyFollowupIds) ?? const <String>[]).toList();
    if (list.remove(mealId)) {
      await prefs.setStringList(_kBodyFollowupIds, list);
    }
  }

  String _formatTime(DateTime dt) {
    final l = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.hour)}:${two(l.minute)}';
  }

  (String, String) _bodyFollowupCopy(String locale, String timeLabel) {
    if (locale == 'en') {
      return (
        'How did you feel after your $timeLabel meal?',
        'Open Tayyibat to log your body response.',
      );
    }
    return (
      'كيف شعرت بعد وجبة الساعة $timeLabel؟',
      'افتح تطبيق الطيبات وسجّل ملاحظاتك.',
    );
  }

  /// إشعار اختباري لمرة واحدة بعد ٥ ثوانٍ — مفيد للتأكد من إذن النظام.
  Future<void> showTest(String title, String body) async {
    if (!_permissionGranted) await requestPermission();
    if (!_permissionGranted) return;
    final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    await _plugin.zonedSchedule(
      9999,
      title,
      body,
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tayyibat_test',
          'Test',
          channelDescription: 'One-off test notification',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          color: Color(0xFFC9A35B),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
