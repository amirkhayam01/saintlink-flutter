import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
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
  bool _termsAccepted = false;

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
      appBar: AppBar(title: const Text('Your details')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    _RouteLine(icon: Icons.my_location, text: journey.pickup.address),
                    for (final stop in journey.via.where((stop) => !stop.isEmpty))
                      _RouteLine(icon: Icons.add_location_alt_outlined, text: stop.address),
                    _RouteLine(icon: Icons.flag_outlined, text: journey.dropoff.address),
                    const SizedBox(height: 8),
                    if (journey.pickupDate != null && journey.pickupTime != null)
                      Text('${Formatting.date(journey.pickupDate!)} at ${journey.pickupTime!.format(context)}${journey.isReturn ? ' · return ${Formatting.date(journey.returnDate!)} at ${journey.returnTime!.format(context)}' : ''}',
                          style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Text('Total to pay', style: TextStyle(fontWeight: FontWeight.w600))),
                        Text(total == null ? '' : Formatting.money(total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Lead passenger'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Full name', errorText: fieldError['customer_name']?.first),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Mobile number', helperText: 'Your driver will use this on the day', errorText: fieldError['customer_phone']?.first),
              validator: (v) => (v ?? '').trim().length < 10 ? 'Please enter a valid mobile number' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Email (optional)', helperText: 'For your confirmation and receipt', errorText: fieldError['customer_email']?.first),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return null;

                return text.contains('@') && text.contains('.') ? null : 'Please enter a valid email address';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              maxLength: 2000,
              decoration: const InputDecoration(labelText: 'Notes for your driver (optional)', hintText: 'Child seat, meeting point, anything we should know'),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _termsAccepted,
              onChanged: (v) => setState(() => _termsAccepted = v ?? false),
              title: Wrap(
                children: [
                  const Text('I accept the '),
                  GestureDetector(
                    onTap: () => showMessage(context, Env.termsUrl),
                    child: const Text('terms and conditions', style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            if (state.bookingError != null) ...[
              const SizedBox(height: 8),
              ErrorNotice(state.bookingError!),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: _termsAccepted && !state.isBooking ? _submit : null,
          child: state.isBooking
              ? const ButtonSpinner()
              : Text(total == null ? 'Confirm booking' : 'Confirm booking · ${Formatting.money(total)}'),
        ),
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colors.inkMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
