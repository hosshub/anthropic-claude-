import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../capture/capture_screen.dart';

/// Today — daily targets ring, plan-fit summary, scan CTA, today's meals,
/// activity snapshot (docs/PRD.md §5, EPIC C3). v0 shows the scaffold shell.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اليوم')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('صباح الخير',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            // TODO: daily targets ring (calories + condition-relevant signal),
            //       e.g. carbs for diabetes, sodium for hypertension, protein
            //       for GLP-1 (EPIC C3 / FR-C3.1).
            _Card(
              child: Column(
                children: [
                  const SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: 0.0,
                      strokeWidth: 11,
                      backgroundColor: WColors.accentSoft,
                      color: WColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('لم تسجّل وجبات اليوم بعد',
                      style: TextStyle(color: WColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaptureScreen()),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: WColors.primary,
                minimumSize: const Size.fromHeight(54),
              ),
              icon: const Icon(Icons.photo_camera),
              label: const Text('صوّر وجبتك'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: WColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: WColors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: child,
      );
}
