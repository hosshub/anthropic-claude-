import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks acceptance of the mandatory medical disclaimer (general-wellness
/// posture — see docs/BRD.md §13). Stored on-device; shown once before use.
class OnboardingService extends ChangeNotifier {
  static const String _kDisclaimerAcceptedAt = 'disclaimer_accepted_at_ms';

  bool _ready = false;
  DateTime? _acceptedAt;

  OnboardingService() {
    _load();
  }

  bool get isReady => _ready;
  bool get hasAcceptedDisclaimer => _acceptedAt != null;
  DateTime? get acceptedAt => _acceptedAt;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_kDisclaimerAcceptedAt);
    _acceptedAt = ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    _ready = true;
    notifyListeners();
  }

  Future<void> acceptDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt(_kDisclaimerAcceptedAt, now.millisecondsSinceEpoch);
    _acceptedAt = now;
    notifyListeners();
  }

  Future<void> resetDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDisclaimerAcceptedAt);
    _acceptedAt = null;
    notifyListeners();
  }
}
