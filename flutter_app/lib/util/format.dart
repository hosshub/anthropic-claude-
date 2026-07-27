import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Locale-aware date and time formatting helpers built on top of `intl`.
/// Keeps UI code free of hand-rolled `'${y}/${m}/${d}'` strings (which
/// silently ignore the locale and surprise English-mode users).
class TFormat {
  TFormat._();

  /// Long, human-readable date: "9 يونيو 2026" / "June 9, 2026".
  static String longDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMMd(locale).format(d.toLocal());
  }

  /// Compact date used in tight rows: "2026/06/09" / "Jun 9, 2026".
  static String compactDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(d.toLocal());
  }

  /// Date + time (24h on Arabic, locale default on English):
  /// "9 يونيو 2026 • 13:45" / "Jun 9, 2026 • 1:45 PM".
  static String dateTime(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale).format(d.toLocal());
    final time = DateFormat.Hm(locale).format(d.toLocal());
    return '$date • $time';
  }

  /// Time of day only, 24-hour: "13:45".
  static String time(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.Hm(locale).format(d.toLocal());
  }
}
