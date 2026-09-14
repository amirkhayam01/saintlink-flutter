import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';

Future<DateTime?> showJourneyDateTimeSheet(
  BuildContext context, {
  required String title,
  required DateTime minimum,
  DateTime? initial,
}) => showModalBottomSheet<DateTime>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: context.colors.surface,
  constraints: const BoxConstraints(maxWidth: 480),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  clipBehavior: Clip.antiAlias,
  builder: (context) =>
      _JourneyDateTimeSheet(title: title, minimum: minimum, initial: initial),
);

class _JourneyDateTimeSheet extends StatefulWidget {
  const _JourneyDateTimeSheet({
    required this.title,
    required this.minimum,
    this.initial,
  });
  final String title;
  final DateTime minimum;
  final DateTime? initial;

  @override
  State<_JourneyDateTimeSheet> createState() => _JourneyDateTimeSheetState();
}

class _JourneyDateTimeSheetState extends State<_JourneyDateTimeSheet> {
  late DateTime _day;
  late final List<DateTime> _dates;
  late final FixedExtentScrollController _days;
  late int _hour;
  late int _minute;
  late final FixedExtentScrollController _hours;
  late final FixedExtentScrollController _minutes;
  late final FixedExtentScrollController _period;
  String? _error;

  DateTime get _selection =>
      DateTime(_day.year, _day.month, _day.day, _hour, _minute);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final first = DateUtils.dateOnly(
      widget.minimum.isAfter(now) ? widget.minimum : now,
    );
    final last = DateUtils.dateOnly(now.add(const Duration(days: 365)));
    _dates = [first];
    for (var i = 1; ; i++) {
      final day = DateTime(first.year, first.month, first.day + i);
      if (day.isAfter(last)) break;
      _dates.add(day);
    }
    var value = widget.initial ?? DateTime.now().add(const Duration(hours: 1));
    if (value.isBefore(widget.minimum)) value = widget.minimum;
    if (DateUtils.dateOnly(value).isAfter(_dates.last)) value = _dates.last;
    _day = DateUtils.dateOnly(value);
    _days = FixedExtentScrollController(
      initialItem: _dates.indexWhere((day) => DateUtils.isSameDay(day, _day)),
    );
    _hour = value.hour;
    _minute = value.minute;
    _hours = FixedExtentScrollController(initialItem: (_hour + 11) % 12);
    _minutes = FixedExtentScrollController(initialItem: _minute);
    _period = FixedExtentScrollController(initialItem: _hour ~/ 12);
  }

  @override
  void dispose() {
    _days.dispose();
    _hours.dispose();
    _minutes.dispose();
    _period.dispose();
    super.dispose();
  }

  void _confirm() {
    final now = DateTime.now();
    final minimum = widget.minimum.isAfter(now) ? widget.minimum : now;
    if (_selection.isBefore(minimum)) {
      setState(
        () => _error =
            'Choose a time after ${Formatting.journeyDateAndTime(minimum)}.',
      );
      return;
    }
    Navigator.of(context).pop(_selection);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scaler = MediaQuery.textScalerOf(context);
    final wheelExtent = scaler.scale(16) * 1.3 + 20;

    Widget wheel({
      required FixedExtentScrollController controller,
      required int count,
      required ValueChanged<int> onChanged,
      required String label,
      String Function(int)? itemLabel,
    }) => Expanded(
      child: Semantics(
        label: label,
        child: CupertinoPicker(
          scrollController: controller,
          itemExtent: wheelExtent,
          onSelectedItemChanged: (value) => setState(() {
            onChanged(value);
            _error = null;
          }),
          selectionOverlay: null,
          diameterRatio: 2.5,
          squeeze: 1.0,
          children: [
            for (var i = 0; i < count; i++)
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    itemLabel?.call(i) ?? i.toString().padLeft(2, '0'),
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    Widget highlighted(Widget child, String key) => Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 0,
          right: 0,
          child: Container(
            key: ValueKey(key),
            height: wheelExtent,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child,
      ],
    );

    final contentHeight =
        wheelExtent * 3 +
        scaler.scale(16) * 2.6 +
        scaler.scale(12) * 3 +
        80 +
        (_error == null ? 0 : scaler.scale(12) * 4);
    return SizedBox(
      height: contentHeight,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close date and time',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Date',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.inkMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Time',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: wheelExtent * 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: highlighted(
                            Semantics(
                              label: 'Date',
                              child: CupertinoPicker.builder(
                                scrollController: _days,
                                itemExtent: wheelExtent,
                                childCount: _dates.length,
                                selectionOverlay: null,
                                diameterRatio: 2.5,
                                squeeze: 1.0,
                                onSelectedItemChanged: (index) => setState(() {
                                  _day = _dates[index];
                                  _error = null;
                                }),
                                itemBuilder: (context, index) {
                                  final day = _dates[index];
                                  return Semantics(
                                    label: Formatting.fullDate(day),
                                    excludeSemantics: true,
                                    child: Center(
                                      child: Text(
                                        Formatting.journeyDateLabel(day),
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 16,
                                          height: 1.3,
                                          fontWeight: FontWeight.w600,
                                          color: colors.ink,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            'date-selection-background',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: highlighted(
                            Row(
                              children: [
                                wheel(
                                  controller: _hours,
                                  count: 12,
                                  itemLabel: (value) => '${value + 1}',
                                  onChanged: (value) => _hour =
                                      (value + 1) % 12 + (_hour ~/ 12) * 12,
                                  label: 'Hour',
                                ),
                                Text(
                                  ':',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.inkMuted,
                                  ),
                                ),
                                wheel(
                                  controller: _minutes,
                                  count: 60,
                                  onChanged: (value) => _minute = value,
                                  label: 'Minute',
                                ),
                                wheel(
                                  controller: _period,
                                  count: 2,
                                  itemLabel: (value) =>
                                      value == 0 ? 'AM' : 'PM',
                                  onChanged: (value) =>
                                      _hour = _hour % 12 + value * 12,
                                  label: 'AM or PM',
                                ),
                              ],
                            ),
                            'time-selection-background',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.inkMuted,
                          ),
                        ),
                      ),
                    if (_error != null) const SizedBox(height: 8),
                    Text(
                      Formatting.journeyDateAndTime(_selection),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: colors.inkMuted),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _confirm,
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
