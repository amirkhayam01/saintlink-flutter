import 'package:intl/intl.dart';

/// Presentation formatting, kept in one place so a date reads the same on every
/// screen.
///
/// All server times arrive as ISO 8601 and are converted to the device's local
/// zone when parsed. The business runs on Europe/London, which for a UK customer
/// is their own zone — the distinction only shows for someone booking from
/// abroad, and showing them their own local time is the honest choice.
class Formatting {
  const Formatting._();

  static final _currency = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _dayAndMonth = DateFormat('EEE d MMM');
  static final _fullDate = DateFormat('EEEE d MMMM y');
  static final _time = DateFormat('HH:mm');

  static String money(double amount, [String currency = 'GBP']) {
    if (currency == 'GBP') return _currency.format(amount);

    return NumberFormat.currency(
      locale: 'en_GB',
      name: currency,
    ).format(amount);
  }

  static String date(DateTime value) => _dayAndMonth.format(value);

  static String weekday(DateTime value) => DateFormat('EEE').format(value);

  static String monthShort(DateTime value) => DateFormat('MMM').format(value);

  static String fullDate(DateTime value) => _fullDate.format(value);

  static String time(DateTime value) => _time.format(value);

  static String time12Hour(DateTime value) =>
      DateFormat('h:mm a').format(value);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String journeyDateLabel(DateTime value, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return _sameDay(value, today)
        ? 'Today'
        : '${weekday(value)} ${monthShort(value)} ${value.day}';
  }

  static String journeyDateAndTime(DateTime value, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final prefix = _sameDay(value, today)
        ? 'Today'
        : _sameDay(value, tomorrow)
        ? 'Tomorrow'
        : weekday(value);
    return '$prefix ${monthShort(value)} ${value.day}, ${time12Hour(value)}';
  }

  static String dateAndTime(DateTime value) =>
      '${_dayAndMonth.format(value)} at ${_time.format(value)}';

  /// Journey length as a person would say it: "1 hr 25 min".
  static String duration(int minutes) {
    if (minutes < 60) return '$minutes min';

    final hours = minutes ~/ 60;
    final remainder = minutes % 60;

    return remainder == 0 ? '$hours hr' : '$hours hr $remainder min';
  }

  static String miles(double value) => '${value.toStringAsFixed(1)} miles';

  /// A countdown for an expiring quote, e.g. "8:04".
  static String countdown(Duration remaining) {
    if (remaining.isNegative) return '0:00';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
