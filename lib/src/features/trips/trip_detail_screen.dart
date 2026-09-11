import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/formatting.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../domain/booking.dart';
import '../payment/payment_controller.dart';
import '../payment/payment_service.dart';
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
    final outcome = await ref.read(paymentControllerProvider(booking.reference).notifier).pay();
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
      appBar: AppBar(title: Text(widget.reference)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: ErrorNotice(error.toString(), onRetry: () => ref.invalidate(tripDetailProvider(widget.reference))))),
        data: (booking) => RefreshIndicator(
          onRefresh: () => ref.refresh(tripDetailProvider(widget.reference).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  StatusChip(label: booking.statusLabel, status: booking.status),
                  const SizedBox(width: 8),
                  StatusChip(label: booking.paymentStatusLabel, status: booking.isPaid ? 'confirmed' : 'pending'),
                ],
              ),
              if (booking.cancellationRequest != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.brand.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    'Cancellation requested — awaiting review. Recommended refund: ${booking.cancellationRequest!.recommendedRefundPercentage.toStringAsFixed(0)}%.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              for (final leg in booking.legs) ...[
                _LegCard(leg: leg, showDirection: booking.isReturn),
                const SizedBox(height: 12),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fare', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      for (final item in booking.fareItems)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(children: [Expanded(child: Text(item.label, style: TextStyle(color: context.colors.inkMuted))), Text(Formatting.money(item.amount, booking.currency))]),
                        ),
                      const Divider(height: 18),
                      Row(children: [const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))), Text(Formatting.money(booking.totalAmount, booking.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DetailRow('Passenger', booking.customerName ?? ''),
                      DetailRow('Phone', booking.customerPhone ?? ''),
                      if (booking.customerEmail != null) DetailRow('Email', booking.customerEmail!),
                      if (booking.customerNotes != null) DetailRow('Notes', booking.customerNotes!),
                    ],
                  ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDirection) Text(leg.isReturnLeg ? 'Return journey' : 'Outward journey', style: const TextStyle(fontWeight: FontWeight.w700)),
            if (leg.pickupAt != null) ...[
              const SizedBox(height: 4),
              Text(Formatting.fullDate(leg.pickupAt!), style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
              Text('Pickup at ${Formatting.time(leg.pickupAt!)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              if (leg.pickupWasAdjusted)
                Text('Adjusted from ${Formatting.time(leg.requestedPickupAt!)} to match your flight', style: const TextStyle(color: AppTheme.brandDark, fontSize: 12)),
            ],
            const SizedBox(height: 10),
            _Stop(icon: Icons.my_location, text: leg.pickupAddress),
            for (final via in leg.viaStops) _Stop(icon: Icons.more_vert, text: via.address),
            _Stop(icon: Icons.flag_outlined, text: leg.dropoffAddress),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (leg.vehicle != null) _Fact(Icons.directions_car_outlined, leg.vehicle!),
                _Fact(Icons.people_outline, '${leg.passengerCount}'),
                if (leg.flight != null) _Fact(Icons.flight, '${leg.flight!.number}${leg.flight!.terminal != null ? ' · ${leg.flight!.terminal}' : ''}'),
                if (leg.meetAndGreet) const _Fact(Icons.waving_hand_outlined, 'Meet & greet'),
                if (leg.includedWaitingMinutes > 0) _Fact(Icons.hourglass_bottom, '${leg.includedWaitingMinutes} min waiting included'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 18, color: context.colors.inkMuted), SizedBox(width: 8), Expanded(child: Text(text))]),
      );
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
