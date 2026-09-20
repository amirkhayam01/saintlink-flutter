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
import '../../widgets/list_row.dart';
import '../auth/auth_controller.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late bool _marketingConsent;

  @override
  void initState() {
    super.initState();
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

  /*
   * The switch moves first so it feels immediate, which means a failed save
   * has to put it back: leaving it flipped would tell the customer we hold a
   * preference we never stored.
   */
  Future<void> _saveMarketing(bool consent) async {
    final customer = ref.read(authControllerProvider).customer;
    if (customer == null) return;

    setState(() => _marketingConsent = consent);

    final saved = await ref.read(profileControllerProvider.notifier).save(
          firstName: customer.firstName,
          lastName: customer.lastName ?? '',
          email: customer.email ?? '',
          marketingConsent: consent,
        );

    if (saved || !mounted) return;

    setState(() => _marketingConsent = !consent);
    showMessage(
      context,
      ref.read(profileControllerProvider).error ??
          'We could not save that just now. Please try again.',
    );
  }

  void _openEditSheet(Customer customer) {
    _firstName.text = customer.firstName;
    _lastName.text = customer.lastName ?? '';
    _email.text = customer.email ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditProfileSheet(
        firstNameController: _firstName,
        lastNameController: _lastName,
        emailController: _email,
        marketingConsent: _marketingConsent,
        onSaved: () {
          setState(() {});
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(authControllerProvider).customer;
    if (customer == null) return const SizedBox.shrink();
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: InnerScreenHeader(
        title: 'Account',
        showBack: false,
        background: InnerScreenHeader.brandBackground(),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _openEditSheet(customer),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
          children: [
            // ── Account Identity Card ──
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openEditSheet(customer),
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppTheme.brand,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _initials(customer),
                        style: const TextStyle(
                          color: AppTheme.midnight,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            customer.email?.isNotEmpty == true
                                ? customer.email!
                                : 'No email added',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customer.phone.isNotEmpty
                                ? customer.phone
                                : customer.maskedPhone,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your number is how you sign in. To change it, '
                            'sign out and sign in with the new one.',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.3,
                              color: colors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // ── General Section ──
            SectionTitle('General'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.bookmark_rounded,
                    title: 'Favourite locations',
                    trailing: const _ComingSoon(),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.format_size_rounded,
                    title: 'Font size',
                    trailing: const _ComingSoon(),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.vpn_key_rounded,
                    title: 'Ride Pin',
                    trailing: const _ComingSoon(),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark mode',
                    trailing: Transform.scale(
                      scale: 0.85,
                      alignment: Alignment.centerRight,
                      child: Switch.adaptive(
                        value: isDark,
                        activeTrackColor: AppTheme.brand,
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggleTheme(),
                      ),
                    ),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.campaign_outlined,
                    title: 'Offers and news',
                    trailing: Transform.scale(
                      scale: 0.85,
                      alignment: Alignment.centerRight,
                      child: Switch.adaptive(
                        value: _marketingConsent,
                        activeTrackColor: AppTheme.brand,
                        onChanged: _saveMarketing,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Socials Section ──
            SectionTitle('Socials'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.camera_alt_outlined,
                    title: 'Instagram',
                    chevron: true,
                    onTap: () => openLink(context, Env.instagramUrl),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.music_note_rounded,
                    title: 'TikTok',
                    chevron: true,
                    onTap: () => openLink(context, Env.tiktokUrl),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.facebook_rounded,
                    title: 'Facebook',
                    chevron: true,
                    onTap: () => openLink(context, Env.facebookUrl),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.share_outlined,
                    title: 'Invite friends',
                    trailing: const _ComingSoon(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── More Section ──
            SectionTitle('More'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.call_outlined,
                    title: 'Call us',
                    trailing: Text(
                      Env.supportPhone,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.inkMuted,
                      ),
                    ),
                    onTap: () => openLink(
                      context,
                      'tel:${Env.supportPhone.replaceAll(' ', '')}',
                    ),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email us',
                    trailing: Text(
                      Env.supportEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.inkMuted,
                      ),
                    ),
                    onTap: () => openLink(context, 'mailto:${Env.supportEmail}'),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.language_rounded,
                    title: 'Website',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: colors.inkMuted,
                    ),
                    onTap: () => openLink(context, Env.websiteUrl),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.description_outlined,
                    title: 'Terms and conditions',
                    chevron: true,
                    onTap: () => openLink(context, Env.termsUrl),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    chevron: true,
                    onTap: () => openLink(context, Env.privacyUrl),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.logout_rounded,
                    iconColor: AppTheme.danger,
                    title: 'Sign out',
                    titleColor: AppTheme.danger,
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (context.mounted) context.go('/');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(Customer customer) {
    final parts = [customer.firstName, customer.lastName ?? '']
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();
    return parts.isEmpty ? '?' : parts;
  }
}

/// Marks a row the design shows but no feature stands behind yet. The row
/// stays visible so the shape of the screen is settled, and stays inert so it
/// never promises something tapping it cannot deliver.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) => Text(
        'Coming soon',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: context.colors.inkMuted,
        ),
      );
}

/// Bottom sheet allowing user to edit their name and email.
class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.marketingConsent,
    required this.onSaved,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final bool marketingConsent;
  final VoidCallback onSaved;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final saved = await ref.read(profileControllerProvider.notifier).save(
          firstName: widget.firstNameController.text,
          lastName: widget.lastNameController.text,
          email: widget.emailController.text,
          marketingConsent: widget.marketingConsent,
        );

    if (saved && mounted) {
      showMessage(context, 'Your details have been updated.');
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Edit details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // First Name
              TextFormField(
                controller: widget.firstNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'First name',
                  hintText: 'e.g. Ada',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  errorText: state.fieldErrors['first_name']?.first,
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Please enter your first name' : null,
              ),
              const SizedBox(height: 14),

              // Last Name
              TextFormField(
                controller: widget.lastNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Last name',
                  hintText: 'e.g. Lovelace',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  errorText: state.fieldErrors['last_name']?.first,
                ),
              ),
              const SizedBox(height: 14),

              // Email
              TextFormField(
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  prefixIcon: const Icon(Icons.mail_outline, size: 20),
                  helperText: 'For booking receipts & notifications',
                  errorText: state.fieldErrors['email']?.first,
                ),
                validator: (v) {
                  final text = (v ?? '').trim();
                  if (text.isEmpty) return null;
                  return text.contains('@') && text.contains('.')
                      ? null
                      : 'Please enter a valid email address';
                },
                onFieldSubmitted: (_) => _submit(),
              ),

              if (state.error != null) ...[
                const SizedBox(height: 12),
                ErrorNotice(state.error!),
              ],
              const SizedBox(height: 20),

              // Save Button
              FilledButton(
                onPressed: state.isSaving ? null : _submit,
                child: state.isSaving
                    ? const ButtonSpinner()
                    : const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
