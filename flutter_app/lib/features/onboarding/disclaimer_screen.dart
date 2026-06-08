import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
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
    if (pos.pixels >= pos.maxScrollExtent - 24) {
      setState(() => _reachedEnd = true);
    }
  }

  Future<void> _accept() async {
    setState(() => _saving = true);
    await context.read<OnboardingService>().acceptDisclaimer();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: widget.readOnly
          ? AppBar(title: Text(l.disclaimer_screenTitle))
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
                        l.disclaimer_welcome,
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.disclaimer_intro,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 14),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: TColors.gold, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.disclaimer_title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: TColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _para(l.disclaimer_intro_body),
                    _heading(l.disclaimer_section_what),
                    _para(l.disclaimer_section_what_body),
                    _heading(l.disclaimer_section_whatNot),
                    _bullet(l.disclaimer_whatNot_1),
                    _bullet(l.disclaimer_whatNot_2),
                    _bullet(l.disclaimer_whatNot_3),
                    _bullet(l.disclaimer_whatNot_4),
                    _heading(l.disclaimer_section_whenDoctor),
                    _para(l.disclaimer_section_whenDoctor_body),
                    _heading(l.disclaimer_section_responsibility),
                    _para(l.disclaimer_section_responsibility_body),
                    _bullet(l.disclaimer_responsibility_1),
                    _bullet(l.disclaimer_responsibility_2),
                    _bullet(l.disclaimer_responsibility_3),
                    _bullet(l.disclaimer_responsibility_4),
                    _heading(l.disclaimer_section_data),
                    _para(l.disclaimer_section_data_body),
                    _heading(l.disclaimer_section_emergency),
                    _para(l.disclaimer_section_emergency_body),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              color: TColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.disclaimer_readyHint,
                              style: const TextStyle(
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l.disclaimer_scrollPrompt,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    PrimaryButton(
                      label: l.disclaimer_action,
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
        padding: const EdgeInsetsDirectional.only(bottom: 4, end: 8),
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
