import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/subscription_service.dart';
import '../../theme/theme.dart';

/// يفتح شاشة الاشتراك. يُعيد true إذا صار المستخدم مشتركاً.
Future<bool> showPaywall(BuildContext context) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const PaywallScreen(),
    ),
  );
  return result == true;
}

/// شاشة الاشتراك: سنوي (بتجربة مجانية) ثم شهري ثم مدى الحياة.
/// تعرض الأسعار كما يرسلها المتجر بعملة المستخدم — لا أسعار مكتوبة يدوياً.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Package? _selected;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // حدّث العروض عند الفتح حتى تظهر الأسعار المحلية الصحيحة.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionService>().refresh();
    });
  }

  List<Package> _packages(SubscriptionService subs) {
    final current = subs.offerings?.current;
    if (current == null) return const [];
    // الترتيب المقصود: سنوي (الأفضل قيمة) ← شهري ← مدى الحياة.
    return [
      if (current.annual != null) current.annual!,
      if (current.monthly != null) current.monthly!,
      if (current.lifetime != null) current.lifetime!,
    ];
  }

  String _priceLine(AppLocalizations l, Package p) {
    final price = p.storeProduct.priceString;
    switch (p.packageType) {
      case PackageType.annual:
        return l.paywall_perYear(price);
      case PackageType.monthly:
        return l.paywall_perMonth(price);
      case PackageType.lifetime:
        return l.paywall_oneTime(price);
      default:
        return price;
    }
  }

  String _title(AppLocalizations l, Package p) => switch (p.packageType) {
        PackageType.annual => l.paywall_annual,
        PackageType.monthly => l.paywall_monthly,
        PackageType.lifetime => l.paywall_lifetime,
        _ => p.storeProduct.title,
      };

  Future<void> _buy() async {
    final l = AppLocalizations.of(context)!;
    final subs = context.read<SubscriptionService>();
    final pkg = _selected;
    if (pkg == null) return;
    setState(() => _busy = true);
    final outcome = await subs.purchase(pkg);
    if (!mounted) return;
    setState(() => _busy = false);
    _handleOutcome(l, outcome);
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context)!;
    final subs = context.read<SubscriptionService>();
    setState(() => _busy = true);
    final outcome = await subs.restore();
    if (!mounted) return;
    setState(() => _busy = false);
    _handleOutcome(l, outcome);
  }

  void _handleOutcome(AppLocalizations l, PurchaseOutcome outcome) {
    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case PurchaseOutcome.success:
        messenger.showSnackBar(SnackBar(content: Text(l.paywall_thanks)));
        Navigator.of(context).pop(true);
      case PurchaseOutcome.nothingToRestore:
        messenger.showSnackBar(
          SnackBar(content: Text(l.paywall_nothingToRestore)),
        );
      case PurchaseOutcome.unavailable:
        messenger
            .showSnackBar(SnackBar(content: Text(l.paywall_unavailable)));
      case PurchaseOutcome.failed:
        messenger.showSnackBar(SnackBar(content: Text(l.paywall_failed)));
      case PurchaseOutcome.cancelled:
        break; // المستخدم ألغى — لا رسالة.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final subs = context.watch<SubscriptionService>();
    final packages = _packages(subs);
    _selected ??= packages.isNotEmpty ? packages.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.paywall_title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.common_close,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.workspace_premium,
                    color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.paywall_subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: TColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _feature(Icons.auto_awesome, l.paywall_feature_scans),
            _feature(Icons.lightbulb_outline, l.paywall_feature_suggestions),
            _feature(Icons.event_note, l.paywall_feature_plans),
            _feature(Icons.volunteer_activism, l.paywall_feature_free,
                muted: true),
            const SizedBox(height: 18),
            if (packages.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  l.paywall_unavailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: TColors.textSecondary),
                ),
              )
            else
              for (final p in packages) ...[
                _packageTile(l, p),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    _busy || _selected == null ? null : _buy,
                style: FilledButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text(
                        l.paywall_subscribe,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l.paywall_renewNote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                height: 1.6,
                color: TColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _busy ? null : _restore,
                  child: Text(l.paywall_restore),
                ),
                const Text('·', style: TextStyle(color: TColors.textSecondary)),
                TextButton(
                  onPressed: () => _open('https://tayyibat.ai/terms.html'),
                  child: Text(l.paywall_terms),
                ),
                const Text('·', style: TextStyle(color: TColors.textSecondary)),
                TextButton(
                  onPressed: () => _open('https://tayyibat.ai/privacy.html'),
                  child: Text(l.paywall_privacy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _feature(IconData icon, String text, {bool muted = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 19,
                color: muted ? TColors.zoneGreen : TColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  height: 1.5,
                  fontSize: 14,
                  color: muted ? TColors.textSecondary : TColors.textPrimary,
                  fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _packageTile(AppLocalizations l, Package p) {
    final selected = _selected?.identifier == p.identifier;
    final isAnnual = p.packageType == PackageType.annual;
    // فترة التجربة تأتي من App Store Connect، فنعرضها فقط إن كانت موجودة.
    final hasTrial = p.storeProduct.introductoryPrice != null;
    return InkWell(
      borderRadius: BorderRadius.circular(TRadii.card),
      onTap: () => setState(() => _selected = p),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.circular(TRadii.card),
          border: Border.all(
            color: selected
                ? TColors.primary
                : TColors.textSecondary.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? TColors.primary : TColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _title(l, p),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: TColors.gold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Text(
                            l.paywall_bestValue,
                            style: const TextStyle(
                              color: TColors.gold,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasTrial
                        ? l.paywall_freeTrial(p.storeProduct.priceString)
                        : _priceLine(l, p),
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
