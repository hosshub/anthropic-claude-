import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/onboarding_service.dart';
import '../../theme/theme.dart';

/// Scroll-gated medical disclaimer. The user must reach the end before the
/// accept button activates. Central to the general-wellness posture
/// (docs/BRD.md §13). `readOnly` mode is used for re-reading from Settings.
class DisclaimerScreen extends StatefulWidget {
  final bool readOnly;
  const DisclaimerScreen({super.key, this.readOnly = false});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  final ScrollController _scroll = ScrollController();
  bool _reachedEnd = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_reachedEnd || !_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 24) {
      setState(() => _reachedEnd = true);
    }
  }

  Future<void> _accept() async {
    setState(() => _saving = true);
    await context.read<OnboardingService>().acceptDisclaimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.readOnly ? AppBar(title: const Text('التنبيه')) : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scroll,
                thumbVisibility: true,
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                  children: [
                    if (!widget.readOnly) ...[
                      const SizedBox(height: 8),
                      Text('Wellness AI',
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      const Text(
                        'قبل البدء، اقرأ التنبيه التالي حتى النهاية.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: WColors.textSecondary, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                    ],
                    const SizedBox(height: 12),
                    _h('تنبيه مهم'),
                    _p('تطبيق Wellness AI أداة لمتابعة الوعي الغذائي ونمط الحياة. '
                        'لا يقدّم تشخيصاً ولا علاجاً ولا يصف دواءً، ولا يحلّ محل '
                        'الطبيب أو أخصائي التغذية.'),
                    _h('دور مقدّم الرعاية'),
                    _p('عندما تربط حسابك بطبيبك أو أخصائي التغذية أو مدرّبك عبر '
                        'رمز الدعوة، فإن القرارات الطبية تبقى من اختصاصه هو '
                        '(شخص مرخّص). التطبيق أداة متابعة وتواصل فقط.'),
                    _h('بياناتك وخصوصيتك'),
                    _p('لا تُشارَك بياناتك مع أي مقدّم رعاية إلا بموافقتك الصريحة، '
                        'ويمكنك إلغاء الربط في أي وقت. يمكنك حذف حسابك وبياناته '
                        'من داخل التطبيق.'),
                    _h('أدوية إنقاص الوزن (GLP-1)'),
                    _p('ميزات مرافقة GLP-1 (تذكيرات، تتبّع البروتين، تسجيل '
                        'الأعراض) للمتابعة فقط ولا تقدّم أي إرشاد للجرعات. '
                        'راجع طبيبك في كل ما يخص الدواء.'),
                    _h('في حالة الطوارئ'),
                    _p('عند ظهور أعراض حادة، اتصل بخدمات الطوارئ فوراً. هذا '
                        'التطبيق ليس مخصّصاً للحالات الطارئة.'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (!widget.readOnly)
              Container(
                color: WColors.surface,
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_reachedEnd)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'مرّر حتى نهاية النص لتفعيل زر الموافقة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: WColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    FilledButton(
                      onPressed: _reachedEnd && !_saving ? _accept : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: WColors.primary,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('أوافق وأتحمّل المسؤولية'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _h(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: WColors.primary)),
      );

  Widget _p(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(t,
            style: const TextStyle(
                fontSize: 15, height: 1.75, color: WColors.textPrimary)),
      );
}
