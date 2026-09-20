import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/tiles.dart';
import 'auth_controller.dart';
import '../../domain/customer.dart';

/// Sign in with a mobile number and a texted code, both steps on one screen.
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
      final sent = await ref
          .read(authRepositoryProvider)
          .requestCode(_phoneForServer);
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
      if (mounted) {
        setState(() => _error = error.firstErrorFor('phone') ?? error.message);
      }
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
      final customer = await ref
          .read(authRepositoryProvider)
          .verifyCode(
            phone: _phoneForServer,
            code: _code.text.trim(),
            name: _name.text,
            deviceName: Theme.of(context).platform == TargetPlatform.iOS
                ? 'iPhone'
                : 'Android phone',
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

  /// What the server is sent. The field shows a +44 prefix, so a customer who
  /// types "7700 900123" without the leading zero still means a UK mobile.
  String get _phoneForServer {
    final raw = _phone.text.trim();
    if (raw.startsWith('+') || raw.startsWith('0')) return raw;

    return '+44$raw';
  }

  @override
  Widget build(BuildContext context) {
    final awaitingCode = _sent != null;
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: awaitingCode
              ? () => setState(() {
                  _sent = null;
                  _error = null;
                  _code.clear();
                })
              : () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
        ),
      ),
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Two soft gold glows, so the page is not a plain grey form.
          const Positioned(top: -140, left: -100, child: _Glow(320)),
          const Positioned(bottom: -120, right: -120, child: _Glow(280)),
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Center(
                child: Image.asset(
                  dark
                      ? 'assets/brand/logo-dark.png'
                      : 'assets/brand/logo-light.png',
                  height: 40,
                ),
              ),
              const SizedBox(height: 32),
              if (!awaitingCode) ...[
                Text(
                  'Sign in with your mobile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'We will text you a six-digit code. No password, nothing to remember.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.inkMuted),
                ),
                const SizedBox(height: 28),
                const FieldLabel('Mobile number'),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '7700 900123',
                    hintStyle: TextStyle(
                      color: colors.placeholder,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 10, 0),
                      child: Text(
                        '+44',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                const FieldLabel('Your name', optional: true),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    hintText: 'Only needed the first time',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
              ] else ...[
                Text(
                  'Enter the code',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.inkMuted),
                    children: [
                      const TextSpan(text: 'Sent to '),
                      TextSpan(
                        text: _sent!.maskedPhone,
                        style: TextStyle(
                          color: colors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '. It expires in a few minutes.'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _OtpBoxes(
                  controller: _code,
                  enabled: !_busy,
                  onCompleted: () {
                    if (!_busy) _verify();
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: _resendIn > 0 || _busy ? null : _requestCode,
                    child: Text(
                      _resendIn > 0
                          ? 'Resend code in ${_resendIn}s'
                          : 'Resend code',
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                ErrorNotice(_error!),
              ],
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: colors.inkMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your number is only used to sign you in and to reach you about your bookings.',
                      style: TextStyle(
                        color: colors.inkMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: _busy
                  ? null
                  : (awaitingCode
                        ? (_code.text.length == 6 ? _verify : null)
                        : (_phone.text.replaceAll(RegExp(r'\D'), '').length >=
                                  10
                              ? _requestCode
                              : null)),
              child: _busy
                  ? const ButtonSpinner()
                  : Text(awaitingCode ? 'Sign in' : 'Send code'),
            ),
            if (kDebugMode)
              TextButton.icon(
                onPressed: _busy
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        ref.read(authControllerProvider.notifier).signInDemo();
                        context.go(widget.redirectTo ?? '/trips');
                      },
                icon: const Icon(Icons.person_outline, size: 18),
                label: const Text('Demo login'),
              ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.brand.withValues(alpha: 0.22),
              AppTheme.brand.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Six digit boxes over one invisible text field, so the keyboard, paste and
/// SMS autofill all keep working while the code reads like a code.
class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({
    required this.controller,
    required this.enabled,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onCompleted;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _focus.dispose();
    super.dispose();
  }

  void _changed() {
    setState(() {});
    if (widget.controller.text.length == 6) widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = widget.controller.text;
    final focused = _focus.hasFocus;

    return GestureDetector(
      onTap: _focus.requestFocus,
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            focused &&
                                i == text.length.clamp(0, 5) &&
                                text.length < 6
                            ? AppTheme.brand
                            : colors.inkFaint,
                        width:
                            focused &&
                                i == text.length.clamp(0, 5) &&
                                text.length < 6
                            ? 2
                            : 1,
                      ),
                    ),
                    child: Text(
                      i < text.length ? text[i] : '',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (i < 5) const SizedBox(width: 8),
              ],
            ],
          ),
          // The real field: zero-size but focusable, so it owns the keyboard.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
