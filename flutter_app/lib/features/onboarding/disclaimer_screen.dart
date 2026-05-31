import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/onboarding_service.dart';
import '../../theme/theme.dart';
import '../../widgets/primary_button.dart';

/// شاشة التنبيه الطبي. يجب على المستخدم تمرير النص حتى النهاية ثم تأكيد القبول
/// قبل دخول التطبيق. يمكن استدعاؤها أيضاً للقراءة فقط من الإعدادات (readOnly).
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
    if (_reachedEnd) return;
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    // اعتبر الوصول للنهاية = ضمن آخر ٢٤ بكسل من المحتوى.
    if (pos.pixels >= pos.maxScrollExtent - 24) {
      setState(() => _reachedEnd = true);
    }
  }

  Future<void> _accept() async {
    setState(() => _saving = true);
    await context.read<OnboardingService>().acceptDisclaimer();
    // الـ AppRoot يلتقط التغيير ويعيد التوجيه إلى الإطار الرئيسي.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: widget.readOnly
          ? AppBar(title: const Text('التنبيه الطبي'))
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scroll,
                thumbVisibility: true,
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  children: [
                    if (!widget.readOnly) ...[
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: TColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: TColors.cardShadow,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'أهلاً بك في الطيبات',
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'قبل البدء، اقرأ التنبيه التالي حتى النهاية.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 14),
                    ],
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: TColors.gold, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تنبيه طبي مهم',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: TColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _para(
                      'تطبيق "الطيبات" أداة معلوماتية تساعدك على متابعة وعيك الغذائي وفق '
                      'مبادئ نظام طبيعي وقفت عليها بنفسك. لا يقدّم التطبيق استشارة طبية، '
                      'ولا يصف علاجاً، ولا يشخّص مرضاً، ولا يحلّ محل الطبيب أو أخصائي '
                      'التغذية.',
                    ),
                    _heading('ما هذا التطبيق؟'),
                    _para(
                      'أداة تذكير ومتابعة لأنماط أكلك، تعطيك إشارات (أخضر/أصفر/أحمر) '
                      'وملخّصات لمساعدتك في الانتباه لما تأكل. الإشارات لأغراض المتابعة '
                      'الذاتية فقط — لا تفسّرها على أنها حكم طبي.',
                    ),
                    _heading('ما هذا التطبيق ليس به؟'),
                    _bullet('لا يصف دواءً أو يطلب إيقاف أي دواء.'),
                    _bullet('لا يشخّص أمراضاً ولا يقترح علاجات.'),
                    _bullet('لا يقدّم نصيحة غذائية مخصّصة لحالتك الصحية.'),
                    _bullet('لا يحلّ محل زيارة الطبيب أو أخصائي التغذية.'),
                    _heading('متى يجب استشارة طبيب؟'),
                    _para(
                      'إذا كان لديك حالة صحية مزمنة (سكري، ضغط، أمراض كلى، أمراض قلب، '
                      'حساسية غذائية، اضطرابات هضمية)، أو إذا كنتِ حاملاً أو مرضعاً، '
                      'أو إذا كنت تتناول أدوية، فعليك مراجعة طبيبك قبل تغيير نظامك '
                      'الغذائي بناءً على ما يعرضه هذا التطبيق.',
                    ),
                    _heading('مسؤوليتك الشخصية'),
                    _para(
                      'باستخدامك التطبيق، تقرّ بأنك:',
                    ),
                    _bullet('قرأت هذا التنبيه وفهمته.'),
                    _bullet('تتحمّل المسؤولية الكاملة عن قراراتك الغذائية.'),
                    _bullet(
                      'لن تستخدم التطبيق بديلاً عن الرعاية الطبية المتخصّصة.',
                    ),
                    _bullet(
                      'تعفي مطوّر التطبيق من أي ضرر مباشر أو غير مباشر ينجم عن '
                      'القرارات الشخصية التي تتخذها بناءً على ما يعرضه التطبيق.',
                    ),
                    _heading('بيانات وجباتك'),
                    _para(
                      'تُحفظ صور وجباتك وملاحظاتك على جهازك بشكل أساسي. لا تُرسل '
                      'بياناتك الصحية لأي طرف ثالث للتسويق. التحليل يمرّ بنموذج '
                      'ذكاء اصطناعي (Gemini) عبر خادم وسيط لا يحتفظ بالصور.',
                    ),
                    _heading('في حالة الطوارئ'),
                    _para(
                      'إذا واجهت أعراضاً صحية حادة، اتصل بخدمات الطوارئ فوراً. '
                      'هذا التطبيق ليس مخصّصاً للاستخدام في الحالات الطارئة.',
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: TColors.gold.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TColors.gold.withOpacity(0.4),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: TColors.gold, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'بقراءتك حتى هنا، أنت جاهز للموافقة. '
                              'يمكنك دائماً إعادة قراءة هذا التنبيه من الإعدادات.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: TColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (!widget.readOnly)
              Container(
                decoration: BoxDecoration(
                  color: TColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: TColors.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_reachedEnd)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'مرّر القراءة حتى نهاية النص لتفعيل زر الموافقة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    PrimaryButton(
                      label: 'أوافق وأتحمّل المسؤولية',
                      icon: Icons.check_circle,
                      loading: _saving,
                      onPressed:
                          _reachedEnd && !_saving ? _accept : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: TColors.primary,
          ),
        ),
      );

  Widget _para(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.75,
            color: TColors.textPrimary,
          ),
        ),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4, right: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: TColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.7,
                  color: TColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
}
