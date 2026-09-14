import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/formatting.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';
import '../../domain/booking.dart';
import '../payment/payment_controller.dart';
import '../payment/payment_service.dart';
import '../payment/test_payment_sheet.dart';
import 'trips_controller.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.reference});

  final String reference;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  bool _busy = false;

  Future<void> _pay(Booking booking) async {
    final outcome = await ref.read(paymentControllerProvider(booking.reference).notifier).pay(
          presentTestSheet: (details) => showTestPaymentSheet(context, details),
        );
    if (!mounted) return;

    switch (outcome) {
      case PaymentOutcome.paid:
        showMessage(context, 'Payment received. Thank you.');
      case PaymentOutcome.cancelled:
        showMessage(context, 'Payment cancelled. Your booking is still saved.');
      case PaymentOutcome.failed:
        showMessage(context, ref.read(paymentControllerProvider(booking.reference)).error ?? 'Your payment could not be taken.');
    }
  }

  Future<void> _cancel(Booking booking) async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _CancelDialog());
    if (reason == null || !mounted) return;

    setState(() => _busy = true);

    try {
      await ref.read(bookingRepositoryProvider).requestCancellation(reference: booking.reference, reason: reason);
      if (!mounted) return;
      showMessage(context, 'Cancellation requested. Our team will review it and confirm any refund.');
      ref.invalidate(tripDetailProvider(widget.reference));
      ref.invalidate(tripsProvider);
    } on ApiException catch (error) {
      if (mounted) showMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(tripDetailProvider(widget.reference));
    final paying = ref.watch(paymentControllerProvider(widget.reference).select((s) => s.isPaying));
    final busy = _busy || paying;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your trip'),
        actions: [
          IconButton(
            tooltip: 'Copy reference',
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: widget.reference));
              if (context.mounted) showMessage(context, 'Reference ${widget.reference} copied');
            },
          ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: ErrorNotice(error.toString(), onRetry: () => ref.invalidate(tripDetailProvider(widget.reference))))),
        data: (booking) => RefreshIndicator(
          onRefresh: () => ref.refresh(tripDetailProvider(widget.reference).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              TicketCard(booking: booking),
              if (booking.cancellationRequest != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: context.colors.tint, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top, size: 18, color: context.colors.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cancellation requested — awaiting review. Recommended refund: ${booking.cancellationRequest!.recommendedRefundPercentage.toStringAsFixed(0)}%.',
                          style: const TextStyle(fontSize: 13, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              for (final leg in booking.legs.where((l) => l.pickupWasAdjusted || l.flight != null || l.includedWaitingMinutes > 0)) ...[
                const SizedBox(height: 16),
                _LegCard(leg: leg, showDirection: booking.isReturn),
              ],
              const SizedBox(height: 16),
              _Panel(
                title: 'Fare',
                child: Column(
                  children: [
                    for (final item in booking.fareItems)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [Expanded(child: Text(item.label, style: TextStyle(color: context.colors.inkMuted))), Text(Formatting.money(item.amount, booking.currency))]),
                      ),
                    if (booking.fareItems.isNotEmpty) Divider(height: 20, color: context.colors.inkFaint),
                    Row(children: [const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))), Text(Formatting.money(booking.totalAmount, booking.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))]),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Lead passenger',
                child: Column(
                  children: [
                    DetailRow('Name', booking.customerName ?? ''),
                    DetailRow('Phone', booking.customerPhone ?? ''),
                    if (booking.customerEmail != null) DetailRow('Email', booking.customerEmail!),
                    if (booking.customerNotes != null) DetailRow('Notes', booking.customerNotes!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: detail.maybeWhen(
        data: (booking) => (booking.canPay || booking.isCancellable)
            ? BottomAction(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (booking.canPay) FilledButton(onPressed: busy ? null : () => _pay(booking), child: Text('Pay ${Formatting.money(booking.totalAmount, booking.currency)}')),
                    if (booking.canPay && booking.isCancellable) const SizedBox(height: 8),
                    if (booking.isCancellable)
                      OutlinedButton(
                        onPressed: busy ? null : () => _cancel(booking),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                        child: const Text('Request cancellation'),
                      ),
                  ],
                ),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

class _LegCard extends StatelessWidget {
  const _LegCard({required this.leg, required this.showDirection});

  final BookingLeg leg;
  final bool showDirection;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: showDirection ? (leg.isReturnLeg ? 'Return journey' : 'Outward journey') : 'Your pickup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leg.pickupAt != null) ...[
            Text('${Formatting.fullDate(leg.pickupAt!)} · ${Formatting.time(leg.pickupAt!)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            if (leg.pickupWasAdjusted)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('Moved from ${Formatting.time(leg.requestedPickupAt!)} to match your flight', style: TextStyle(color: context.colors.accent, fontSize: 12)),
              ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              if (leg.flight != null) _Fact(Icons.flight, '${leg.flight!.number}${leg.flight!.terminal != null ? ' · ${leg.flight!.terminal}' : ''}${leg.flight!.status != null ? ' · ${leg.flight!.status}' : ''}'),
              if (leg.meetAndGreet) const _Fact(Icons.waving_hand_outlined, 'Meet & greet'),
              if (leg.includedWaitingMinutes > 0) _Fact(Icons.hourglass_bottom, '${leg.includedWaitingMinutes} min waiting included'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: context.colors.inkMuted), SizedBox(width: 4), Text(text, style: TextStyle(fontSize: 13, color: context.colors.inkMuted))]);
}

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request cancellation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Our team reviews every request and confirms any refund under the cancellation policy.', style: TextStyle(fontSize: 13, color: context.colors.inkMuted)),
          const SizedBox(height: 12),
          TextField(controller: _reason, maxLines: 3, maxLength: 1000, autofocus: true, decoration: const InputDecoration(labelText: 'Reason'), onChanged: (_) => setState(() {})),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Keep booking')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.danger, minimumSize: const Size(0, 44)),
          onPressed: _reason.text.trim().isEmpty ? null : () => Navigator.of(context).pop(_reason.text.trim()),
          child: const Text('Request'),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.inkFaint)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
