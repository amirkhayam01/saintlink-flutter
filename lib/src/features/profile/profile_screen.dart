import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/links.dart';
import '../../core/theme.dart';
import '../../core/theme_controller.dart';
import '../../domain/customer.dart';
import '../../widgets/common.dart';
import '../../widgets/inner_screen_header.dart';
import '../../widgets/tiles.dart';
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

    final saved = await ref
        .read(profileControllerProvider.notifier)
        .save(
          firstName: _firstName.text,
          lastName: _lastName.text,
          email: _email.text,
          marketingConsent: _marketingConsent,
        );

    if (saved && mounted) {
      showMessage(context, 'Your details have been updated.');
      if (context.canPop()) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final customer = ref.watch(authControllerProvider).customer;
    if (customer == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: InnerScreenHeader(
        title: 'Your details',
        showBack: false,
        background: InnerScreenHeader.brandBackground(),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _IdentityCard(customer: customer),
            const SizedBox(height: 28),
            const SectionTitle(
              'Name and email',
              subtitle: 'Used on your bookings and confirmation emails.',
            ),
            const SizedBox(height: 14),
            const FieldLabel('First name'),
            TextFormField(
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'e.g. Ada',
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                errorText: state.fieldErrors['first_name']?.first,
              ),
              validator: (v) => (v ?? '').trim().isEmpty
                  ? 'Please enter your first name'
                  : null,
            ),
            const SizedBox(height: 14),
            const FieldLabel('Last name'),
            TextFormField(
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'e.g. Lovelace',
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                errorText: state.fieldErrors['last_name']?.first,
              ),
            ),
            const SizedBox(height: 14),
            const FieldLabel('Email', optional: true),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: const Icon(Icons.mail_outline, size: 20),
                helperText: 'For booking confirmations and receipts',
                errorText: state.fieldErrors['email']?.first,
              ),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return null;

                return text.contains('@') && text.contains('.')
                    ? null
                    : 'Please enter a valid email address';
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Offers and news'),
              subtitle: Text(
                'Occasional emails from Saints Link. You can turn this off at any time.',
                style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
              ),
              value: _marketingConsent,
              onChanged: (v) => setState(() => _marketingConsent = v),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              ErrorNotice(state.error!),
            ],
            const SizedBox(height: 28),
            const SectionTitle('Appearance'),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: const IconDisc(Icons.dark_mode_outlined, size: 40),
              title: const Text('Dark mode'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              'Need a hand?',
              subtitle: 'Our office is in Southampton and answers the phone.',
            ),
            const SizedBox(height: 14),
            ContactTile(
              icon: Icons.call_outlined,
              title: 'Call us',
              subtitle: Env.supportPhone,
              onTap: () => openLink(
                context,
                'tel:${Env.supportPhone.replaceAll(' ', '')}',
              ),
            ),
            const SizedBox(height: 10),
            ContactTile(
              icon: Icons.mail_outline,
              title: 'Email us',
              subtitle: Env.supportEmail,
              onTap: () => openLink(context, 'mailto:${Env.supportEmail}'),
            ),
            const SizedBox(height: 10),
            ContactTile(
              icon: Icons.language,
              title: 'Website',
              subtitle: Env.websiteUrl.replaceFirst('https://', ''),
              trailingIcon: Icons.open_in_new,
              onTap: () => openLink(context, Env.websiteUrl),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go('/');
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: state.isSaving ? null : _save,
          child: state.isSaving
              ? const ButtonSpinner()
              : const Text('Save changes'),
        ),
      ),
    );
  }
}

/// Who is signed in: initials, name, and the number that is their identity.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final initials = [customer.firstName, customer.lastName ?? '']
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2)
        .join();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.midnight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.brand,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(
                color: AppTheme.midnight,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customer.maskedPhone,
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your number is how you sign in. To change it, sign out and sign in with the new one.',
                  style: TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 11,
                    height: 1.3,
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
