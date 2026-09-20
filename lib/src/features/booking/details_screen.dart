import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/theme.dart';
import '../../core/links.dart';
import '../../widgets/common.dart';
import '../../widgets/tiles.dart';
import '../auth/auth_controller.dart';
import 'booking_flow_controller.dart';

/// Step three: who is travelling. Prefilled but editable; the booker is not always the passenger.
class DetailsStage extends ConsumerStatefulWidget {
  const DetailsStage({super.key});

  @override
  ConsumerState<DetailsStage> createState() => DetailsStageState();
}

/// The form's content for the journey sheet's last stage. The sheet's button
/// calls [submit]; on success the confirmation is pushed over everything.
class DetailsStageState extends ConsumerState<DetailsStage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  final _notes = TextEditingController();
  late final TextEditingController _flight;
  late final TextEditingController _terminal;

  @override
  void initState() {
    super.initState();
    final customer = ref.read(authControllerProvider).customer;
    _name = TextEditingController(text: customer?.name ?? '');
    _phone = TextEditingController(text: customer?.phone ?? '');
    _email = TextEditingController(text: customer?.email ?? '');
    final journey = ref.read(bookingFlowProvider).journey;
    _flight = TextEditingController(text: journey.outboundFlightNumber ?? '');
    _terminal = TextEditingController(text: journey.outboundTerminal ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _notes.dispose();
    _flight.dispose();
    _terminal.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_form.currentState!.validate()) return;

    final booking = await ref
        .read(bookingFlowProvider.notifier)
        .confirmBooking(
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
    final fieldError = state.fieldErrors;

    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Lead passenger'),
          const SizedBox(height: 14),
          const FieldLabel('Full name'),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'e.g. Ada Lovelace',
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              errorText: fieldError['customer_name']?.first,
            ),
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 14),
          const FieldLabel('Mobile number'),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: '07700 900123',
              prefixIcon: const Icon(Icons.phone_iphone, size: 20),
              errorText: fieldError['customer_phone']?.first,
            ),
            validator: (v) => (v ?? '').trim().length < 10
                ? 'Please enter a valid mobile number'
                : null,
          ),
          const SizedBox(height: 14),
          const FieldLabel('Email', optional: true),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'you@example.com',
              prefixIcon: const Icon(Icons.mail_outline, size: 20),
              errorText: fieldError['customer_email']?.first,
            ),
            validator: (v) {
              final text = (v ?? '').trim();
              if (text.isEmpty) return null;

              return text.contains('@') && text.contains('.')
                  ? null
                  : 'Please enter a valid email address';
            },
          ),
          const SizedBox(height: 24),
          if (journey.touchesAirport) ...[
            const SectionTitle('Flight details'),
            const SizedBox(height: 14),
            const FieldLabel('Flight number', optional: true),
            TextFormField(
              controller: _flight,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'e.g. BA123',
                prefixIcon: const Icon(Icons.flight_takeoff, size: 20),
                errorText: fieldError['outbound_flight_number']?.first,
              ),
              validator: (value) {
                final text = (value ?? '').trim().toUpperCase();
                if (text.isEmpty) return null;
                return RegExp(r'^[A-Z0-9]{2,4}\s?\d{1,4}[A-Z]?$')
                            .hasMatch(text) &&
                        text.length <= 20
                    ? null
                    : 'Please enter a valid flight number';
              },
              onChanged: (value) => ref
                  .read(bookingFlowProvider.notifier)
                  .updateFlightDetails(
                    flightNumber: value.trim().toUpperCase(),
                  ),
            ),
            const SizedBox(height: 14),
            const FieldLabel('Terminal', optional: true),
            TextFormField(
              controller: _terminal,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'e.g. T5',
                errorText: fieldError['outbound_terminal']?.first,
              ),
              validator: (value) => (value ?? '').trim().length > 100
                  ? 'Terminal is too long'
                  : null,
              onChanged: (value) => ref
                  .read(bookingFlowProvider.notifier)
                  .updateFlightDetails(terminal: value.trim()),
            ),
            const SizedBox(height: 24),
          ],
          const SectionTitle('For your driver'),
          const SizedBox(height: 14),
          const FieldLabel('Notes', optional: true),
          TextFormField(
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            maxLength: 2000,
            buildCounter: (
              _, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
            decoration: const InputDecoration(
              hintText: 'Add a note for your driver',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: Icon(Icons.chat_bubble_outline, size: 20),
              ),
            ),
          ),
          if (state.bookingError != null) ...[
            const SizedBox(height: 16),
            ErrorNotice(state.bookingError!),
          ],
          const SizedBox(height: 20),
          _TermsLine(
            onTerms: () => openLink(context, Env.termsUrl),
            onPrivacy: () => openLink(context, Env.privacyUrl),
          ),
        ],
      ),
    );
  }
}

/// Consent by action: confirming is accepting, with the terms one tap away.
class _TermsLine extends StatelessWidget {
  const _TermsLine({required this.onTerms, required this.onPrivacy});

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final link = TextStyle(
      color: colors.ink,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: TextStyle(color: colors.inkMuted, fontSize: 13, height: 1.4),
        children: [
          const TextSpan(text: 'By confirming you agree to our '),
          WidgetSpan(
            child: GestureDetector(
              onTap: onTerms,
              child: Text(
                'terms and conditions',
                style: link.copyWith(fontSize: 13),
              ),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            child: GestureDetector(
              onTap: onPrivacy,
              child: Text('privacy policy', style: link.copyWith(fontSize: 13)),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
