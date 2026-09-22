import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/inner_screen_header.dart';
import '../../widgets/booking_summary.dart';
import '../auth/auth_controller.dart';
import '../payment/payment_controller.dart';
import '../payment/payment_service.dart';
import '../payment/test_payment_sheet.dart';
import '../../domain/booking.dart';
import 'booking_flow_controller.dart';

/// The booking exists; take payment if the server says it can be paid now.
class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  Future<void> _pay(Booking booking) async {
    final outcome = await ref
        .read(paymentControllerProvider(booking.reference).notifier)
        .pay(
          presentTestSheet: (details) => showTestPaymentSheet(context, details),
        );

    if (outcome == PaymentOutcome.cancelled && mounted) {
      showMessage(
        context,
        'Payment cancelled. Your booking is saved — you can pay from My trips.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingFlowProvider.select((s) => s.booking));
    final signedIn = ref.watch(authControllerProvider).isSignedIn;

    if (booking == null) {
      return const Scaffold(body: Center(child: Text('No booking to show.')));
    }

    final payment = ref.watch(paymentControllerProvider(booking.reference));

    void leave(String location) {
      ref.read(bookingFlowProvider.notifier).reset();
      context.go(location);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const InnerScreenHeader(title: 'Your booking', showBack: false),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
          children: [
            _ConfirmedHero(booking: booking, paid: payment.isPaid),
            const SizedBox(height: 28),
            BookingSummary(booking: booking, paidOverride: payment.isPaid),
            const SizedBox(height: 20),
            _NextSteps(
              booking: booking,
              paid: payment.isPaid,
              signedIn: signedIn,
            ),
            if (payment.error != null) ...[
              const SizedBox(height: 12),
              ErrorNotice(payment.error!),
            ],
            if (signedIn) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => leave('/'),
                  child: const Text('Back to home'),
                ),
              ),
            ],
          ],
        ),
        // One primary action: pay while it is due, otherwise on to the trips.
        bottomNavigationBar: BottomAction(
          child: booking.canPay && !payment.isPaid
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: payment.isPaying ? null : () => _pay(booking),
                      child: payment.isPaying
                          ? const ButtonSpinner()
                          : Text(
                              'Pay ${Formatting.money(booking.totalAmount, booking.currency)} now',
                            ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => leave(signedIn ? '/trips' : '/'),
                      child: Text(signedIn ? 'Pay later' : 'Done'),
                    ),
                  ],
                )
              : FilledButton(
                  onPressed: () => leave(signedIn ? '/trips' : '/'),
                  child: Text(signedIn ? 'View my trips' : 'Done'),
                ),
        ),
      ),
    );
  }
}

/// The moment of relief: a green check, the words, and the reference ready
/// to copy for whoever else needs it.
class _ConfirmedHero extends StatelessWidget {
  const _ConfirmedHero({required this.booking, required this.paid});

  final Booking booking;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          paid ? 'Paid and booked' : 'Booking confirmed',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          paid
              ? 'Your transfer is paid for and in the diary.'
              : 'Your transfer is booked. Here is everything you need.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.inkMuted, fontSize: 14),
        ),
        const SizedBox(height: 14),
        Material(
          color: colors.card,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: booking.reference));
              if (context.mounted) {
                showMessage(context, 'Reference ${booking.reference} copied');
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.inkFaint),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ref ',
                    style: TextStyle(color: colors.inkMuted, fontSize: 13),
                  ),
                  Text(
                    booking.reference,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.copy_rounded, size: 16, color: colors.inkMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// What happens now, in the order it happens.
class _NextSteps extends StatelessWidget {
  const _NextSteps({
    required this.booking,
    required this.paid,
    required this.signedIn,
  });

  final Booking booking;
  final bool paid;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final steps = <(IconData, String)>[
      if (booking.customerEmail != null)
        (Icons.mail_outline, 'Confirmation sent to ${booking.customerEmail}'),
      if (!paid && booking.canPay)
        (
          Icons.credit_card,
          'Pay now to secure the booking, or later from My trips',
        ),
      if (!paid && !booking.canPay)
        (Icons.support_agent, 'Our team will confirm your booking shortly'),
      (
        Icons.directions_car_outlined,
        'Your driver\'s details arrive the day before travel',
      ),
      if (!signedIn)
        (
          Icons.phone_iphone,
          'Sign in with your mobile number to see this trip in the app any time',
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.inkFaint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happens next',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          for (final (icon, text) in steps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: colors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: colors.ink,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
