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
          Text(subtitle!, style: const TextStyle(color: AppTheme.inkMuted)),
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
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF991B1B)))),
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
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppTheme.inkMuted))),
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
    final colour = AppTheme.statusColor(status);

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
  const BottomAction({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.inkFaint)),
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

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
