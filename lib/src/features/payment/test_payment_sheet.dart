import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../domain/payment_sheet_details.dart';

/// The stand-in for Stripe's sheet while the backend runs the fake driver.
///
/// Deliberately unlike a real card form — no card fields, a warning banner,
/// "Test payment" in the title — so nobody watching a demo, or a tester with
/// the wrong build, could mistake it for one. Returns true if Pay was tapped.
Future<bool> showTestPaymentSheet(BuildContext context, PaymentSheetDetails details) async {
  final paid = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _TestPaymentSheet(details: details),
  );

  return paid ?? false;
}

class _TestPaymentSheet extends StatelessWidget {
  const _TestPaymentSheet({required this.details});

  final PaymentSheetDetails details;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Test payment', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.tint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.science_outlined, color: colors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Payments are in test mode. No card is needed and no money will be taken. The booking will be marked as paid.',
                    style: TextStyle(fontSize: 13, color: colors.ink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Text(details.merchantName, style: TextStyle(color: colors.inkMuted))),
              Text(Formatting.money(details.amount, details.currency), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Pay ${Formatting.money(details.amount, details.currency)} (test)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
