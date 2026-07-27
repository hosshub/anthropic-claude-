import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tayyibat/data/meal_repository.dart';
import 'package:tayyibat/features/history/edit_items_sheet.dart';
import 'package:tayyibat/l10n/generated/app_localizations.dart';
import 'package:tayyibat/models/analysis_result.dart';
import 'package:tayyibat/models/meal.dart';

/// v1.2.1 review recommendation — deleting every item must disable saving
/// and show the "needs at least one item" message (no empty meals).
/// The repository is never touched on this path, so the opener throws.
void main() {
  testWidgets('deleting the last item blocks saving', (tester) async {
    final repo = MealRepository(
      dbOpener: () async => throw StateError('db must not be opened'),
    );
    final meal = Meal(
      id: 'm1',
      capturedAt: DateTime(2026, 7, 24, 12),
      imagePath: null,
      overallScore: 100,
      scoreLabelAr: 'ممتاز',
      scoreExplanationAr: '',
      suggestions: const [],
      warnings: const [],
      items: [
        FoodItem.fromJson(const {'name_ar': 'أرز', 'zone': 'green'}),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<MealRepository>.value(
        value: repo,
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showEditItemsSheet(context, meal),
                  child: const Text('فتح'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();

    expect(find.text('أرز'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Empty message appears and the save button is disabled.
    expect(
      find.text('تحتاج الوجبة إلى عنصر واحد على الأقل.'),
      findsOneWidget,
    );
    final saveButton = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(saveButton.onPressed, isNull);
  });
}
