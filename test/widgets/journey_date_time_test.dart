import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/features/booking/journey_date_time_sheet.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('compact date and time wheels fits narrow large text: $dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final initial = DateUtils.dateOnly(DateTime.now())
          .add(const Duration(days: 2, hours: 14, minutes: 30));
      DateTime? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showJourneyDateTimeSheet(
                    context,
                    title: 'Pickup date & time',
                    minimum: DateTime.now(),
                    initial: initial,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.byType(TimePickerDialog), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(CupertinoPicker), findsNWidgets(4));
      expect(tester.getSize(find.byType(BottomSheet)).height, lessThan(560));
      final dateBackground = tester.getRect(
        find.byKey(const ValueKey('date-selection-background')),
      );
      final timeBackground = tester.getRect(
        find.byKey(const ValueKey('time-selection-background')),
      );
      expect(timeBackground.left - dateBackground.right, 12);
      final wheels = find.byType(CupertinoPicker);
      expect(
        tester.getCenter(wheels.at(0)).dy,
        tester.getCenter(wheels.at(1)).dy,
      );
      expect(tester.takeException(), isNull);
      final hours = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(1),
      );
      hours.scrollController!.jumpToItem(3);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Confirm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(
        result,
        DateTime(initial.year, initial.month, initial.day, 16, 30),
      );
      expect(find.byType(BottomSheet), findsNothing);
    });
  }

  for (final initialHour in [0, 12]) {
    testWidgets('AM/PM maps noon and midnight correctly from $initialHour', (
      tester,
    ) async {
      final day = DateUtils.dateOnly(DateTime.now())
          .add(const Duration(days: 2));
      final initial = DateTime(day.year, day.month, day.day, initialHour, 5);
      DateTime? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showJourneyDateTimeSheet(
                    context,
                    title: 'Pickup date & time',
                    minimum: DateTime.now(),
                    initial: initial,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(initialHour == 0 ? '12:05 AM' : '12:05 PM'),
        findsOneWidget,
      );
      final period = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(3),
      );
      period.scrollController!.jumpToItem(initialHour == 0 ? 1 : 0);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(
        result,
        DateTime(day.year, day.month, day.day, initialHour == 0 ? 12 : 0, 5),
      );
    });
  }

  testWidgets(
    'date wheel changes date, rejects earlier return time and cancels safely',
    (tester) async {
      final minimum = DateUtils.dateOnly(DateTime.now())
          .add(const Duration(days: 2, hours: 14));
      DateTime? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showJourneyDateTimeSheet(
                    context,
                    title: 'Return date & time',
                    minimum: minimum,
                    initial: minimum.add(const Duration(hours: 1)),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final hours = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(1),
      );
      hours.scrollController!.jumpToItem(0);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Choose a time after'), findsOneWidget);
      expect(result, isNull);
      final nextDay = minimum.add(const Duration(days: 1));
      final dates = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).first,
      );
      dates.scrollController!.jumpToItem(1);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, DateTime(nextDay.year, nextDay.month, nextDay.day, 13));
      result = null;
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close date and time'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    },
  );
}
