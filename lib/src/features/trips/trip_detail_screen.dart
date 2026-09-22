import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/formatting.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/inner_screen_header.dart';
import '../../widgets/booking_summary.dart';
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
    final outcome = await ref
        .read(paymentControllerProvider(booking.reference).notifier)
        .pay(
          presentTestSheet: (details) => showTestPaymentSheet(context, details),
        );
    if (!mounted) return;

    switch (outcome) {
      case PaymentOutcome.paid:
        showMessage(context, 'Payment received. Thank you.');
      case PaymentOutcome.cancelled:
        showMessage(context, 'Payment cancelled. Your booking is still saved.');
      case PaymentOutcome.failed:
        showMessage(
          context,
          ref.read(paymentControllerProvider(booking.reference)).error ??
              'Your payment could not be taken.',
        );
    }
  }

  Future<void> _cancel(Booking booking) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelDialog(),
    );
    if (reason == null || !mounted) return;

    setState(() => _busy = true);

    try {
      await ref
          .read(bookingRepositoryProvider)
          .requestCancellation(reference: booking.reference, reason: reason);
      if (!mounted) return;
      showMessage(
        context,
        'Cancellation requested. Our team will review it and confirm any refund.',
      );
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
    final paying = ref.watch(
      paymentControllerProvider(widget.reference).select((s) => s.isPaying),
    );
    final busy = _busy || paying;
    final booking = detail.value;

    return Scaffold(
      appBar: InnerScreenHeader(
        title: 'Your trip',
        background: InnerScreenHeader.midnightBackground(),
        contentHeight: _TripHeader.height,
        headerContent: _TripHeader(
          reference: widget.reference,
          booking: booking,
          onCopy: () async {
            await Clipboard.setData(ClipboardData(text: widget.reference));
            if (context.mounted) {
              showMessage(context, 'Reference ${widget.reference} copied');
            }
          },
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorNotice(
              error.toString(),
              onRetry: () =>
                  ref.invalidate(tripDetailProvider(widget.reference)),
            ),
          ),
        ),
        data: (booking) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(tripDetailProvider(widget.reference).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              if (booking.cancellationRequest != null) ...[
                _Notice(
                  icon: Icons.hourglass_top_rounded,
                  text:
                      'Cancellation requested and awaiting review. '
                      'Recommended refund: ${booking.cancellationRequest!.recommendedRefundPercentage.toStringAsFixed(0)}%.',
                ),
                const SizedBox(height: 16),
              ],
              BookingSummary(booking: booking),
              const SizedBox(height: 20),
              const SectionTitle('Lead passenger'),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      DetailRow('Name', booking.customerName ?? ''),
                      DetailRow('Phone', booking.customerPhone ?? ''),
                      if (booking.customerEmail != null)
                        DetailRow('Email', booking.customerEmail!),
                      if (booking.customerNotes != null)
                        DetailRow('Notes', booking.customerNotes!),
                    ],
                  ),
                ),
              ),
              if (booking.isCancellable) ...[
                const SizedBox(height: 20),
                // Quiet on purpose: a way out, not a call to action.
                Center(
                  child: TextButton.icon(
                    onPressed: busy ? null : () => _cancel(booking),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Request cancellation'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: booking != null && booking.canPay
          ? BottomAction(
              child: FilledButton(
                onPressed: busy ? null : () => _pay(booking),
                child: Text(
                  'Pay ${Formatting.money(booking.totalAmount, booking.currency)}',
                ),
              ),
            )
          : null,
    );
  }
}

/// Reference, status and what it costs, on the header so the eye lands on
/// them first. Blank while the trip is still loading.
class _TripHeader extends StatelessWidget {
  const _TripHeader({
    required this.reference,
    required this.booking,
    required this.onCopy,
  });

  final String reference;
  final Booking? booking;
  final VoidCallback onCopy;

  static const height = 104.0;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withValues(alpha: 0.7);
    final booking = this.booking;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BOOKING REFERENCE',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reference,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: muted,
                        semanticLabel: 'Copy reference',
                      ),
                    ],
                  ),
                ),
                if (booking != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _HeaderChip(
                        label: booking.statusLabel,
                        color: AppTheme.statusColor(booking.status),
                      ),
                      const SizedBox(width: 6),
                      _HeaderChip(
                        label: booking.paymentStatusLabel,
                        color: booking.isPaid
                            ? AppTheme.success
                            : AppTheme.brand,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (booking != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Formatting.money(booking.totalAmount, booking.currency),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  booking.isReturn ? 'Return · total' : 'Total',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A status pill drawn for the dark header: the colour as a tint and text.
class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Color.lerp(color, Colors.white, 0.35),
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, height: 1.35, color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
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
          Text(
            'Our team reviews every request and confirms any refund under the cancellation policy.',
            style: TextStyle(fontSize: 13, color: context.colors.inkMuted),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLines: 3,
            maxLength: 1000,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Reason'),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep booking'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.danger,
            minimumSize: const Size(0, 44),
          ),
          onPressed: _reason.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_reason.text.trim()),
          child: const Text('Request'),
        ),
      ],
    );
  }
}
