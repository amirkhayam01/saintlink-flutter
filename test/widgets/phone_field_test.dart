import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/countries.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/widgets/phone_field.dart';

// One number shape reaches the server whatever the customer typed, and the
// field itself only takes digits.
void main() {
  Country gb() => Country.byIso('GB')!;

  group('PhoneController', () {
    testWidgets('the trunk zero goes, the dialling code comes', (t) async {
      final c = PhoneController(country: gb(), initial: '07700 900123');
      expect(c.e164, '+447700900123');
      expect(c.isPlausible, isTrue);
    });

    testWidgets('a full international number picks its country', (t) async {
      final c = PhoneController(country: gb(), initial: '+33 6 12 34 56 78');
      expect(c.country.iso, 'FR');
      expect(c.national.text, '612345678');
      expect(c.e164, '+33612345678');
    });

    testWidgets('a pasted +number switches country mid-way', (t) async {
      final c = PhoneController(country: gb());
      c.national.text = '+1 415 555 0123';
      expect(c.country.iso, 'US');
      expect(c.e164, '+14155550123');
    });

    testWidgets('shared codes resolve to the main country', (t) async {
      expect(Country.byDial('447700900123')!.iso, 'GB');
      expect(Country.byDial('14155550123')!.iso, 'US');
      expect(Country.byDial('12461234567')!.iso, 'BB');
      expect(Country.byDial('79161234567')!.iso, 'RU');
    });

    testWidgets('too short is not plausible', (t) async {
      expect(PhoneController(country: gb(), initial: '12345').isPlausible, isFalse);
    });

    testWidgets('defaults to United Kingdom regardless of device locale', (t) async {
      t.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(t.platformDispatcher.clearLocaleTestValue);
      expect(PhoneController().country.iso, 'GB');
      t.platformDispatcher.localeTestValue = const Locale('fr', 'FR');
      expect(PhoneController().country.iso, 'GB');
    });
  });

  testWidgets('the field takes digits only and offers a country picker', (
    tester,
  ) async {
    final controller = PhoneController(country: gb());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Form(child: PhoneField(controller: controller, validate: true)),
        ),
      ),
    );
    expect(find.text('+44'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'abc 07700-900123#');
    expect(controller.national.text, ' 07700900123');
    expect(controller.e164, '+447700900123');

    await tester.tap(find.text('+44'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'germ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Germany'));
    await tester.pumpAndSettle();
    expect(find.text('+49'), findsOneWidget);
    expect(controller.e164, '+497700900123');

    await tester.enterText(find.byType(TextField), '12');
    expect(
      Form.of(tester.element(find.byType(PhoneField))).validate(),
      isFalse,
    );
    await tester.pumpAndSettle();
    expect(find.text(PhoneField.invalidMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
