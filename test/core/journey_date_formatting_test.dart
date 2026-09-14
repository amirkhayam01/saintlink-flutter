import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/formatting.dart';

void main() {
  final now = DateTime(2026, 8, 22, 23, 50);
  test('today wheel hides the date and selected field keeps month and day', () {
    final value = DateTime(2026, 8, 22, 15, 5);
    expect(Formatting.journeyDateLabel(value, now: now), 'Today');
    expect(
      Formatting.journeyDateAndTime(value, now: now),
      'Today Aug 22, 3:05 PM',
    );
  });
  test('tomorrow is relative only in the selected date and time', () {
    final value = DateTime(2026, 8, 23, 15, 5);
    expect(Formatting.journeyDateLabel(value, now: now), 'Sun Aug 23');
    expect(
      Formatting.journeyDateAndTime(value, now: now),
      'Tomorrow Aug 23, 3:05 PM',
    );
  });
  test('tomorrow crosses a year boundary by calendar date', () {
    expect(
      Formatting.journeyDateAndTime(
        DateTime(2027, 1, 1, 0, 5),
        now: DateTime(2026, 12, 31, 23, 55),
      ),
      'Tomorrow Jan 1, 12:05 AM',
    );
  });
  test('later dates keep the weekday', () {
    expect(
      Formatting.journeyDateAndTime(DateTime(2026, 8, 24, 9, 5), now: now),
      'Mon Aug 24, 9:05 AM',
    );
  });
}
