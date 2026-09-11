import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../domain/customer.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late bool _marketingConsent;

  @override
  void initState() {
    super.initState();
    // The router only lets signed-in customers here, so there is a customer.
    final customer = ref.read(authControllerProvider).customer!;
    _firstName = TextEditingController(text: customer.firstName);
    _lastName = TextEditingController(text: customer.lastName ?? '');
    _email = TextEditingController(text: customer.email ?? '');
    _marketingConsent = customer.marketingConsent;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final saved = await ref.read(profileControllerProvider.notifier).save(
          firstName: _firstName.text,
          lastName: _lastName.text,
          email: _email.text,
          marketingConsent: _marketingConsent,
        );

    if (saved && mounted) {
      showMessage(context, 'Your details have been updated.');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final Customer customer = ref.watch(authControllerProvider).customer!;

    return Scaffold(
      appBar: AppBar(title: const Text('Your details')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const SectionTitle('Mobile number', subtitle: 'This is how you sign in. To change it, sign out and sign in with the new number.'),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: customer.maskedPhone,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Mobile number'),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Name and email', subtitle: 'Used on your bookings and confirmation emails.'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'First name', errorText: state.fieldErrors['first_name']?.first),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Please enter your first name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Last name', errorText: state.fieldErrors['last_name']?.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              decoration: InputDecoration(labelText: 'Email', helperText: 'Optional — for booking confirmations', errorText: state.fieldErrors['email']?.first),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return null;

                return text.contains('@') && text.contains('.') ? null : 'Please enter a valid email address';
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Offers and news'),
              subtitle: const Text('Occasional emails from Saints Link. You can turn this off at any time.', style: TextStyle(color: AppTheme.inkMuted, fontSize: 13)),
              value: _marketingConsent,
              onChanged: (v) => setState(() => _marketingConsent = v),
            ),
            if (state.error != null) ...[const SizedBox(height: 12), ErrorNotice(state.error!)],
          ],
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: state.isSaving ? null : _save,
          child: state.isSaving
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : const Text('Save changes'),
        ),
      ),
    );
  }
}
