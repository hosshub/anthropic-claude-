import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayyibat/services/profile_service.dart';

Future<ProfileService> _ready() async {
  final p = ProfileService();
  while (!p.isReady) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  return p;
}

/// v1.3.0 — first / last / nickname on the profile, with the Today greeting
/// preferring nickname, then first name.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores first, last, and nickname', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await _ready();
    await p.setFirstName('حسام');
    await p.setLastName('ناصف');
    await p.setNickname('حسّوم');
    expect(p.firstName, 'حسام');
    expect(p.lastName, 'ناصف');
    expect(p.nickname, 'حسّوم');
  });

  test('greetingName prefers nickname, then first name, else null', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await _ready();
    expect(p.greetingName, isNull);
    await p.setFirstName('حسام');
    expect(p.greetingName, 'حسام');
    await p.setNickname('حسّوم');
    expect(p.greetingName, 'حسّوم');
    await p.setNickname('');
    expect(p.greetingName, 'حسام');
  });

  test('migrates a legacy display name into the first name', () async {
    // v1.2 stored the greeting under profile_display_name.
    SharedPreferences.setMockInitialValues({
      'profile_display_name': 'Hossam',
    });
    final p = await _ready();
    expect(p.firstName, 'Hossam');
    expect(p.greetingName, 'Hossam');
  });

  test('reset clears every name field', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await _ready();
    await p.setFirstName('حسام');
    await p.setLastName('ناصف');
    await p.setNickname('حسّوم');
    await p.reset();
    expect(p.firstName, isNull);
    expect(p.lastName, isNull);
    expect(p.nickname, isNull);
    expect(p.greetingName, isNull);
  });
}
