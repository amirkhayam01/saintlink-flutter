import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import 'auth_controller.dart';
import '../../domain/customer.dart';

/// Sign in with a mobile number and a texted code.
///
/// Two steps on one screen, because the second step is only meaningful in the
/// context of the first: the customer needs to see which number was texted to
/// know whether to wait or go back and fix a typo.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.redirectTo});

  /// Where to go once signed in, so a customer sent here from "My trips" lands
  /// on their trips and not on the home screen.
  final String? redirectTo;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _code = TextEditingController();
  SignInCodeRequest? _sent;
  bool _busy = false;
  String? _error;
  int _resendIn = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    _code.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestCode() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final sent = await ref.read(authRepositoryProvider).requestCode(_phone.text);
      if (!mounted) return;
      setState(() {
        _sent = sent;
        _resendIn = sent.resendAfterSeconds;
      });
      _resendTimer?.cancel();
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _resendIn <= 0) {
          timer.cancel();

          return;
        }
        setState(() => _resendIn--);
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.firstErrorFor('phone') ?? error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final customer = await ref.read(authRepositoryProvider).verifyCode(
            phone: _phone.text,
            code: _code.text.trim(),
            name: _name.text,
            deviceName: Theme.of(context).platform == TargetPlatform.iOS ? 'iPhone' : 'Android phone',
          );
      await ref.read(authControllerProvider.notifier).completeSignIn(customer);
      if (mounted) context.go(widget.redirectTo ?? '/trips');
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.firstErrorFor('code') ?? error.message);
        _code.clear();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final awaitingCode = _sent != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        leading: awaitingCode
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _sent = null; _error = null; _code.clear(); }))
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          if (!awaitingCode) ...[
            const SectionTitle('Your mobile number', subtitle: 'We will text you a code. No password to remember.'),
            const SizedBox(height: 20),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Mobile number', hintText: '07700 900123', prefixIcon: Icon(Icons.phone_iphone)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Your name (first time only)', prefixIcon: Icon(Icons.person_outline)),
            ),
          ] else ...[
            SectionTitle('Enter the code', subtitle: 'Sent to ${_sent!.maskedPhone}. It expires in a few minutes.'),
            const SizedBox(height: 20),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              autofocus: true,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: '······'),
              onChanged: (value) {
                if (value.length == 6 && !_busy) _verify();
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _resendIn > 0 || _busy ? null : _requestCode,
                child: Text(_resendIn > 0 ? 'Resend code in ${_resendIn}s' : 'Resend code'),
              ),
            ),
          ],
          if (_error != null) ...[const SizedBox(height: 12), ErrorNotice(_error!)],
          const SizedBox(height: 24),
          const Text(
            'Your number is only used to sign you in and to reach you about your bookings.',
            style: TextStyle(color: AppTheme.inkMuted, fontSize: 13),
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: _busy
              ? null
              : (awaitingCode ? (_code.text.length == 6 ? _verify : null) : (_phone.text.trim().length >= 10 ? _requestCode : null)),
          child: _busy
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(awaitingCode ? 'Sign in' : 'Send code'),
        ),
      ),
    );
  }
}
