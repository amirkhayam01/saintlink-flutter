import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import '../payment/payment_service.dart';
import '../../domain/booking.dart';
import 'booking_flow_controller.dart';

/// The booking exists. Now take payment, if payments are on.
///
/// The booking is created before the card is asked for, so a customer who
/// abandons the payment sheet still has a booking the office can chase — and
/// still has the confirmation email. `can_pay` from the server decides whether
/// a pay button appears at all; while payments are disabled the office confirms
/// and takes payment on the day.
class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  bool _paying = false;
  bool _paid = false;
  String? _error;

  Future<void> _pay(Booking booking) async {
    setState(() {
      _paying = true;
      _error = null;
    });

    try {
      final outcome = await ref.read(paymentServiceProvider).payForBooking(booking.reference);

      if (!mounted) return;

      switch (outcome) {
        case PaymentOutcome.paid:
          setState(() => _paid = true);
        case PaymentOutcome.cancelled:
          showMessage(context, 'Payment cancelled. Your booking is saved — you can pay from My trips.');
        case PaymentOutcome.failed:
          setState(() => _error = 'Your payment could not be taken. Please try again.');
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingFlowProvider.select((s) => s.booking));
    final signedIn = ref.watch(authControllerProvider).isSignedIn;

    if (booking == null) {
      return const Scaffold(body: Center(child: Text('No booking to show.')));
    }

    final leg = booking.legs.isEmpty ? null : booking.legs.first;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Booking received')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.brand, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_paid ? Icons.verified : Icons.check_circle_outline, size: 36, color: AppTheme.midnight),
                  const SizedBox(height: 10),
                  Text(_paid ? 'Paid and booked' : 'Thanks — we have your booking', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.midnight)),
                  const SizedBox(height: 4),
                  Text('Reference ${booking.reference}', style: const TextStyle(color: AppTheme.midnight, fontWeight: FontWeight.w600)),
                  if (booking.customerEmail != null) ...[
                    const SizedBox(height: 4),
                    Text('Confirmation sent to ${booking.customerEmail}', style: const TextStyle(color: AppTheme.midnight, fontSize: 13)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (leg != null) DetailRow('Pickup', '${leg.pickupAddress}\n${leg.pickupAt == null ? '' : Formatting.dateAndTime(leg.pickupAt!)}'),
                    if (leg != null) DetailRow('Destination', leg.dropoffAddress),
                    if (booking.isReturn && booking.legs.length > 1)
                      DetailRow('Return', booking.legs[1].pickupAt == null ? '' : Formatting.dateAndTime(booking.legs[1].pickupAt!)),
                    DetailRow('Vehicle', booking.vehicle ?? ''),
                    DetailRow('Total', Formatting.money(booking.totalAmount, booking.currency), emphasise: true),
                    DetailRow('Payment', _paid ? 'Paid' : booking.paymentStatusLabel),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[const SizedBox(height: 12), ErrorNotice(_error!)],
            const SizedBox(height: 16),
            if (!signedIn)
              const Text(
                'Sign in with your mobile number to see this booking in the app at any time. Your confirmation email has everything you need either way.',
                style: TextStyle(color: AppTheme.inkMuted, fontSize: 13),
              ),
          ],
        ),
        bottomNavigationBar: BottomAction(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (booking.canPay && !_paid) ...[
                FilledButton(
                  onPressed: _paying ? null : () => _pay(booking),
                  child: _paying
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text('Pay ${Formatting.money(booking.totalAmount, booking.currency)} now'),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton(
                onPressed: () {
                  ref.read(bookingFlowProvider.notifier).reset();
                  context.go(signedIn ? '/trips' : '/');
                },
                child: Text(signedIn ? 'View my trips' : 'Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
