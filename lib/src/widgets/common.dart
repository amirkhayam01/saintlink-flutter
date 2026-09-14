import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A section heading in the app's voice: short, dark, no decoration.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: TextStyle(color: context.colors.inkMuted)),
        ],
      ],
    );
  }
}

/// The inline error the API's message is shown in. Red is only ever used for
/// something that is wrong, so this is the one place the colour appears.
class ErrorNotice extends StatelessWidget {
  const ErrorNotice(this.message, {super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.errorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.errorBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: context.colors.errorText))),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// A key/value row on review and detail screens.
class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key, this.emphasise = false});

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: context.colors.inkMuted))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: emphasise ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// A status pill: the label the server already wrote, in the status colour.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    // Pending statuses come back as the darker gold, which goes dull on
    // midnight; the ground-aware accent is the same colour by day.
    final statusColour = AppTheme.statusColor(status);
    final colour = statusColour == AppTheme.brandDark ? context.colors.accent : statusColour;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: colour, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// The fixed bottom action the website's mobile layout uses, carried over so
/// the primary button is always where the thumb is.
class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.child, this.verticalPadding = 12});

  final Widget child;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, verticalPadding, 20, verticalPadding + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(top: BorderSide(color: context.colors.inkFaint)),
      ),
      child: child,
    );
  }
}

/// A numeric stepper for passengers and luggage.
class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
        IconButton.outlined(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        IconButton.outlined(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// The spinner a primary button shows in place of its label while it works.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(strokeWidth: 2.5, color: Theme.of(context).colorScheme.onPrimary),
    );
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// "Step 2 of 3" as a row of bars: filled for done and current, faint for
/// what is left. Keeps the customer oriented through vehicle → details → done.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.step, this.of = 3});

  final int step;
  final int of;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= of; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= step ? AppTheme.brand : context.colors.inkFaint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < of) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

/// Pickup and destination on one line with an arrow, for headers where the
/// full route card would take too much room.
class RouteSummary extends StatelessWidget {
  const RouteSummary({super.key, required this.from, required this.to, this.subtitle});

  final String from;
  final String to;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: Text(from, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_forward, size: 14, color: colors.inkMuted)),
            Flexible(child: Text(to, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: TextStyle(color: colors.inkMuted, fontSize: 12)),
        ],
      ],
    );
  }
}
