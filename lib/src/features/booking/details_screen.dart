import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../core/links.dart';
import '../../domain/vehicle_category.dart';
import '../../widgets/common.dart';
import '../../widgets/route_timeline.dart';
import '../../widgets/vehicle_image.dart';
import 'journey_draft.dart';
import '../auth/auth_controller.dart';
import 'booking_flow_controller.dart';

/// Step three: who is travelling, and the terms.
///
/// Prefilled from the signed-in customer when there is one, but every field is
/// editable — the person booking is not always the person travelling.
class DetailsScreen extends ConsumerStatefulWidget {
  const DetailsScreen({super.key});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    final customer = ref.read(authControllerProvider).customer;
    _name = TextEditingController(text: customer?.name ?? '');
    _phone = TextEditingController(text: customer?.phone ?? '');
    _email = TextEditingController(text: customer?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    final booking = await ref.read(bookingFlowProvider.notifier).confirmBooking(
          customerName: _name.text,
          customerPhone: _phone.text,
          customerEmail: _email.text,
          specialInstructions: _notes.text,
        );

    if (booking != null && mounted) {
      context.go('/book/confirmed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingFlowProvider);
    final journey = state.journey;
    final vehicle = state.selectedVehicle;
    final total = state.totalDue;
    final fieldError = state.fieldErrors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your details'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(18),
          child: Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 14), child: StepIndicator(step: 2)),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _SummaryCard(journey: journey, vehicle: vehicle, total: total),
            const SizedBox(height: 28),
            const SectionTitle('Lead passenger', subtitle: 'The person the driver will meet. It does not have to be you.'),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(hintText: 'Full name', prefixIcon: const Icon(Icons.person_outline, size: 20), errorText: fieldError['customer_name']?.first),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(hintText: 'Mobile number', prefixIcon: const Icon(Icons.phone_iphone, size: 20), helperText: 'Your driver will use this on the day', errorText: fieldError['customer_phone']?.first),
              validator: (v) => (v ?? '').trim().length < 10 ? 'Please enter a valid mobile number' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Email (optional)', prefixIcon: const Icon(Icons.mail_outline, size: 20), helperText: 'For your confirmation and receipt', errorText: fieldError['customer_email']?.first),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return null;

                return text.contains('@') && text.contains('.') ? null : 'Please enter a valid email address';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              maxLength: 2000,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(hintText: 'Notes for your driver (optional)', helperText: 'Child seat, meeting point, anything we should know', prefixIcon: Padding(padding: EdgeInsets.only(bottom: 22), child: Icon(Icons.chat_bubble_outline, size: 20))),
            ),
            if (state.bookingError != null) ...[
              const SizedBox(height: 16),
              ErrorNotice(state.bookingError!),
            ],
            const SizedBox(height: 20),
            _TermsLine(onTerms: () => openLink(context, Env.termsUrl), onPrivacy: () => openLink(context, Env.privacyUrl)),
          ],
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: state.isBooking ? null : _submit,
          child: state.isBooking
              ? const ButtonSpinner()
              : Text(total == null ? 'Confirm booking' : 'Confirm booking · ${Formatting.money(total)}'),
        ),
      ),
    );
  }
}

/// What is being booked, at a glance: the car, the route, the price.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.journey, required this.vehicle, required this.total});

  final JourneyDraft journey;
  final VehicleCategory? vehicle;
  final double? total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time = journey.pickupTime == null ? '' : MaterialLocalizations.of(context).formatTimeOfDay(journey.pickupTime!, alwaysUse24HourFormat: true);
    final returnTime = journey.returnTime == null ? '' : MaterialLocalizations.of(context).formatTimeOfDay(journey.returnTime!, alwaysUse24HourFormat: true);

    return Container(
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.inkFaint)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (vehicle != null)
            Row(
              children: [
                SizedBox(width: 104, height: 80, child: VehicleImage(vehicle!.slug)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle!.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(journey.isReturn ? 'Return · same vehicle both ways' : 'One way', style: TextStyle(color: colors.inkMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(total == null ? '' : Formatting.money(total!), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.3)),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: RouteTimeline(
              dense: true,
              points: [
                RoutePoint(
                  address: journey.pickup.address,
                  label: journey.pickupDate == null ? 'Pickup' : '${Formatting.date(journey.pickupDate!)} · $time',
                  detail: journey.outboundFlightNumber?.trim().isNotEmpty == true ? 'Flight ${journey.outboundFlightNumber!.trim().toUpperCase()}' : null,
                ),
                for (final stop in journey.via.where((stop) => !stop.isEmpty)) RoutePoint(address: stop.address, label: 'Stop'),
                RoutePoint(
                  address: journey.dropoff.address,
                  label: journey.isReturn && journey.returnDate != null ? 'Return ${Formatting.date(journey.returnDate!)} · $returnTime' : 'Destination',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Consent by action, the way the large booking apps do it: confirming is
/// accepting, and the terms are one tap away rather than behind a checkbox
/// most people tick without reading.
class _TermsLine extends StatelessWidget {
  const _TermsLine({required this.onTerms, required this.onPrivacy});

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final link = TextStyle(color: colors.ink, fontWeight: FontWeight.w600, decoration: TextDecoration.underline);

    return Text.rich(
      TextSpan(
        style: TextStyle(color: colors.inkMuted, fontSize: 13, height: 1.4),
        children: [
          const TextSpan(text: 'By confirming you agree to our '),
          WidgetSpan(child: GestureDetector(onTap: onTerms, child: Text('terms and conditions', style: link.copyWith(fontSize: 13)))),
          const TextSpan(text: ' and '),
          WidgetSpan(child: GestureDetector(onTap: onPrivacy, child: Text('privacy policy', style: link.copyWith(fontSize: 13)))),
          const TextSpan(text: '. Free cancellation under the policy; our team confirms any refund.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
