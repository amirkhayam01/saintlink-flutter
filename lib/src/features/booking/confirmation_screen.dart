import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';
import '../auth/auth_controller.dart';
import '../payment/payment_controller.dart';
import '../payment/payment_service.dart';
import '../payment/test_payment_sheet.dart';
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
  Future<void> _pay(Booking booking) async {
    final outcome = await ref.read(paymentControllerProvider(booking.reference).notifier).pay(
          presentTestSheet: (details) => showTestPaymentSheet(context, details),
        );

    if (outcome == PaymentOutcome.cancelled && mounted) {
      showMessage(context, 'Payment cancelled. Your booking is saved — you can pay from My trips.');
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(payment.isPaid ? 'Paid and booked' : 'Booking received'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(18),
            child: Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 14), child: StepIndicator(step: 3)),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            TicketCard(
              booking: booking,
              headline: payment.isPaid ? 'Paid and booked' : 'Thanks — we have your booking',
              paidOverride: payment.isPaid,
            ),
            const SizedBox(height: 20),
            _NextSteps(booking: booking, paid: payment.isPaid, signedIn: signedIn),
            if (payment.error != null) ...[const SizedBox(height: 12), ErrorNotice(payment.error!)],
          ],
        ),
        bottomNavigationBar: BottomAction(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (booking.canPay && !payment.isPaid) ...[
                FilledButton(
                  onPressed: payment.isPaying ? null : () => _pay(booking),
                  child: payment.isPaying
                      ? const ButtonSpinner()
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

/// What happens now, in the order it happens.
class _NextSteps extends StatelessWidget {
  const _NextSteps({required this.booking, required this.paid, required this.signedIn});

  final Booking booking;
  final bool paid;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final steps = <(IconData, String)>[
      if (booking.customerEmail != null) (Icons.mail_outline, 'Confirmation sent to ${booking.customerEmail}'),
      if (!paid && booking.canPay) (Icons.credit_card, 'Pay now to secure the booking, or later from My trips'),
      if (!paid && !booking.canPay) (Icons.support_agent, 'Our team will confirm your booking shortly'),
      (Icons.directions_car_outlined, 'Your driver\'s details arrive the day before travel'),
      if (!signedIn) (Icons.phone_iphone, 'Sign in with your mobile number to see this trip in the app any time'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.inkFaint)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What happens next', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final (icon, text) in steps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: AppTheme.brandDark),
                  const SizedBox(width: 10),
                  Expanded(child: Text(text, style: TextStyle(color: colors.ink, fontSize: 14, height: 1.35))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
