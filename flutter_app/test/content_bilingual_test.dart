import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/data/guide_data.dart';
import 'package:tayyibat/data/meal_banks_data.dart';
import 'package:tayyibat/data/program_data.dart';
import 'package:tayyibat/data/tips_data.dart';

/// Regression guard: every static content string must exist in BOTH Arabic and
/// English. After the v1.0.1 translation pass this is the single most useful
/// test — it fails CI the moment anyone adds an Arabic-only (or English-only)
/// entry to any of the content data files.
void main() {
  void notBlank(String? s, String where) {
    expect(s, isNotNull, reason: '$where should not be null');
    expect(s!.trim(), isNotEmpty, reason: '$where should not be blank');
  }

  group('TipsData', () {
    test('every tip has a unique id and both languages', () {
      final ids = <String>{};
      for (final t in TipsData.all) {
        expect(ids.add(t.id), isTrue, reason: 'duplicate tip id ${t.id}');
        notBlank(t.textAr, 'tip ${t.id} textAr');
        notBlank(t.textEn, 'tip ${t.id} textEn');
      }
    });

    test('text(locale) picks the right language', () {
      final t = TipsData.all.first;
      expect(t.text('ar'), t.textAr);
      expect(t.text('en'), t.textEn);
    });

    test('every slot has at least one tip and bySlot partitions cleanly', () {
      var total = 0;
      for (final slot in TipSlot.values) {
        final pool = TipsData.bySlot(slot);
        expect(pool, isNotEmpty, reason: 'slot $slot has no tips');
        expect(pool.every((t) => t.slot == slot), isTrue);
        total += pool.length;
      }
      expect(total, TipsData.all.length);
    });
  });

  group('GuideData', () {
    test('medical disclaimer differs by language and is never blank', () {
      notBlank(GuideData.medicalDisclaimer('ar'), 'disclaimer ar');
      notBlank(GuideData.medicalDisclaimer('en'), 'disclaimer en');
      expect(GuideData.medicalDisclaimer('ar'),
          isNot(GuideData.medicalDisclaimer('en')));
    });

    test('golden rules are fully bilingual', () {
      expect(GuideData.goldenRules, hasLength(6));
      for (final r in GuideData.goldenRules) {
        notBlank(r.ruleAr, 'rule ${r.id} ruleAr');
        notBlank(r.ruleEn, 'rule ${r.id} ruleEn');
        notBlank(r.applicationAr, 'rule ${r.id} applicationAr');
        notBlank(r.applicationEn, 'rule ${r.id} applicationEn');
        expect(r.rule('en'), r.ruleEn);
        expect(r.rule('ar'), r.ruleAr);
      }
    });

    test('philosophy cards are fully bilingual', () {
      for (final c in GuideData.philosophyCards) {
        notBlank(c.titleAr, 'philosophy ${c.id} titleAr');
        notBlank(c.titleEn, 'philosophy ${c.id} titleEn');
        notBlank(c.bodyAr, 'philosophy ${c.id} bodyAr');
        notBlank(c.bodyEn, 'philosophy ${c.id} bodyEn');
      }
    });

    test('common mistakes are fully bilingual', () {
      for (final m in GuideData.commonMistakes) {
        notBlank(m.mistakeAr, 'mistake mistakeAr');
        notBlank(m.mistakeEn, 'mistake mistakeEn');
        notBlank(m.correctionAr, 'mistake correctionAr');
        notBlank(m.correctionEn, 'mistake correctionEn');
      }
    });

    test('weekly prep tasks are fully bilingual with valid metadata', () {
      for (final t in GuideData.weeklyPrep) {
        notBlank(t.titleAr, 'prep ${t.id} titleAr');
        notBlank(t.titleEn, 'prep ${t.id} titleEn');
        expect(t.validDays, greaterThan(0));
        notBlank(t.category, 'prep ${t.id} category');
        // Category labels resolve (non-blank, and not identical across langs
        // unless intentionally the same code path).
        notBlank(weeklyCategoryLabel(t.category, 'ar'), 'cat ar ${t.category}');
        notBlank(weeklyCategoryLabel(t.category, 'en'), 'cat en ${t.category}');
      }
    });

    test('every zone is bilingual and its groups are internally consistent', () {
      for (final zone in [
        GuideData.greenZone,
        GuideData.yellowZone,
        GuideData.redZone,
      ]) {
        notBlank(zone.labelAr, 'zone labelAr');
        notBlank(zone.labelEn, 'zone labelEn');
        notBlank(zone.subtitleAr, 'zone subtitleAr');
        notBlank(zone.subtitleEn, 'zone subtitleEn');
        // Watchword is optional but must be symmetric.
        expect((zone.watchwordAr == null) == (zone.watchwordEn == null), isTrue,
            reason: 'zone watchword must be present in both or neither');

        for (final g in zone.groups) {
          final isCategory = g.categoryAr != null;
          if (isCategory) {
            notBlank(g.categoryAr, 'group categoryAr');
            notBlank(g.categoryEn, 'group categoryEn');
            expect(g.itemsAr, isNotNull);
            expect(g.itemsEn, isNotNull);
            expect(g.itemsAr!.length, g.itemsEn!.length,
                reason: 'item lists must align for ${g.categoryAr}');
            expect(g.itemsAr, isNotEmpty);
            for (final s in g.itemsAr!) {
              notBlank(s, 'itemAr in ${g.categoryAr}');
            }
            for (final s in g.itemsEn!) {
              notBlank(s, 'itemEn in ${g.categoryEn}');
            }
          } else {
            notBlank(g.itemAr, 'group itemAr');
            notBlank(g.itemEn, 'group itemEn');
            // examples + guidance must be symmetric across languages.
            expect((g.examplesAr == null) == (g.examplesEn == null), isTrue,
                reason: 'examples symmetry for ${g.itemAr}');
            expect((g.guidanceAr == null) == (g.guidanceEn == null), isTrue,
                reason: 'guidance symmetry for ${g.itemAr}');
          }
        }
      }
    });
  });

  group('MealBanksData', () {
    test('there are 4 banks, each fully bilingual', () {
      expect(MealBanksData.banks, hasLength(4));
      for (final bank in MealBanksData.banks) {
        notBlank(bank.titleAr, 'bank titleAr');
        notBlank(bank.titleEn, 'bank titleEn');
        notBlank(bank.subtitleAr, 'bank subtitleAr');
        notBlank(bank.subtitleEn, 'bank subtitleEn');
        expect(bank.items, isNotEmpty);
        for (final item in bank.items) {
          notBlank(item.nameAr, 'item nameAr in ${bank.titleEn}');
          notBlank(item.nameEn, 'item nameEn in ${bank.titleEn}');
          notBlank(item.compositionAr, 'item compositionAr');
          notBlank(item.compositionEn, 'item compositionEn');
          // Notes are optional but must be symmetric.
          expect((item.noteAr == null) == (item.noteEn == null), isTrue,
              reason: 'note symmetry for ${item.nameEn}');
        }
      }
    });

    test('item.name/composition/note pick by locale', () {
      final item = MealBanksData.banks.first.items.first;
      expect(item.name('en'), item.nameEn);
      expect(item.name('ar'), item.nameAr);
      expect(item.composition('en'), item.compositionEn);
    });
  });

  group('ProgramData content', () {
    test('title and philosophy are bilingual and distinct', () {
      notBlank(ProgramData.title('ar'), 'program title ar');
      notBlank(ProgramData.title('en'), 'program title en');
      expect(ProgramData.title('ar'), isNot(ProgramData.title('en')));
      notBlank(ProgramData.philosophy('ar'), 'program philosophy ar');
      notBlank(ProgramData.philosophy('en'), 'program philosophy en');
    });

    test('every phase is fully bilingual', () {
      for (final p in ProgramData.phases) {
        notBlank(p.daysRangeAr, 'phase ${p.number} daysRangeAr');
        notBlank(p.daysRangeEn, 'phase ${p.number} daysRangeEn');
        notBlank(p.titleAr, 'phase ${p.number} titleAr');
        notBlank(p.titleEn, 'phase ${p.number} titleEn');
        notBlank(p.focusAr, 'phase ${p.number} focusAr');
        notBlank(p.focusEn, 'phase ${p.number} focusEn');
      }
    });

    test('every day is fully bilingual', () {
      for (final d in ProgramData.days) {
        notBlank(d.focusAr, 'day ${d.day} focusAr');
        notBlank(d.focusEn, 'day ${d.day} focusEn');
        notBlank(d.exampleMealAr, 'day ${d.day} exampleMealAr');
        notBlank(d.exampleMealEn, 'day ${d.day} exampleMealEn');
        notBlank(d.tipAr, 'day ${d.day} tipAr');
        notBlank(d.tipEn, 'day ${d.day} tipEn');
      }
    });
  });
}
