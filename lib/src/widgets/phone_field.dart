import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/countries.dart';
import '../core/theme.dart';

/// A mobile number as a country and the digits after its dialling code.
/// Both places that ask for one share this, so the server always receives
/// the same shape: `+447700900123`, whatever the customer typed.
class PhoneController extends ChangeNotifier {
  /// [initial] may be a full international number (`+33612345678`), which
  /// picks the country, or a national one for [country], or nothing.
  PhoneController({Country? country, String initial = ''})
    : _country = country ?? Country.fallback {
    national = TextEditingController();
    national.addListener(_absorbInternational);
    _setNational(initial.trim());
  }

  void _setNational(String text) {
    national.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// The default country for the app: the business is British.
  static Country deviceCountry() => Country.fallback;

  Country _country;
  Country get country => _country;
  set country(Country value) {
    if (value == _country) return;
    _country = value;
    notifyListeners();
  }

  /// The digits the customer types; the dialling code is never in here.
  late final TextEditingController national;

  /// A pasted or typed `+…` number carries its own country: take it, and
  /// leave only the rest in the field.
  void _absorbInternational() {
    final text = national.text;
    if (!text.contains('+')) return;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final match = Country.byDial(digits);
    if (match == null) {
      _setNational(digits);
      return;
    }
    _country = match;
    _setNational(digits.substring(match.dial.length));
    notifyListeners();
  }

  /// The national digits without the trunk zero: `07700…` is `7700…` once
  /// the dialling code is in front of it.
  String get digits => national.text
      .replaceAll(RegExp(r'\D'), '')
      .replaceFirst(RegExp(r'^0+'), '');

  /// Enough digits to be a mobile number somewhere; the server knows more.
  bool get isPlausible => digits.length >= 6 && digits.length <= 12;

  /// What the server is sent.
  String get e164 => '+${_country.dial}$digits';

  @override
  void dispose() {
    national.dispose();
    super.dispose();
  }
}

/// A phone number field: a tappable country in front of the digits.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.errorText,
    this.validate = false,
    this.onChanged,
    this.fontSize = 16,
  });

  final PhoneController controller;
  final bool autofocus;
  final TextInputAction textInputAction;

  /// A server-side error to show under the field.
  final String? errorText;

  /// Whether the enclosing [Form] should reject an implausible number.
  final bool validate;
  final ValueChanged<String>? onChanged;
  final double fontSize;

  static const invalidMessage = 'Please enter a valid mobile number';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final country = controller.country;
        return TextFormField(
          controller: controller.national,
          keyboardType: TextInputType.phone,
          autofocus: autofocus,
          autofillHints: const [AutofillHints.telephoneNumber],
          textInputAction: textInputAction,
          // Digits and spaces; a plus only so a full number can be pasted,
          // and the controller folds that into the country at once.
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]')),
          ],
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: country.iso == 'GB' ? '7700 900123' : 'Mobile number',
            hintStyle: TextStyle(
              color: colors.placeholder,
              fontWeight: FontWeight.w500,
            ),
            errorText: errorText,
            prefixIcon: _CountryPrefix(
              country: country,
              fontSize: fontSize,
              onTap: () async {
                FocusScope.of(context).unfocus();
                final picked = await showCountryPicker(context, country);
                if (picked != null) controller.country = picked;
              },
            ),
            prefixIconConstraints: const BoxConstraints(),
          ),
          validator: validate
              ? (_) => controller.isPlausible ? null : invalidMessage
              : null,
          onChanged: onChanged,
        );
      },
    );
  }
}

class _CountryPrefix extends StatelessWidget {
  const _CountryPrefix({
    required this.country,
    required this.fontSize,
    required this.onTap,
  });

  final Country country;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '${country.name}, +${country.dial}. Change country',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country.flag, style: TextStyle(fontSize: fontSize + 2)),
              const SizedBox(width: 6),
              Text(
                '+${country.dial}',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
              Icon(Icons.expand_more_rounded, size: 18, color: colors.inkMuted),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// A searchable list of countries; returns the one chosen, or null.
Future<Country?> showCountryPicker(BuildContext context, Country current) {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _CountryPicker(current: current),
  );
}

class _CountryPicker extends StatefulWidget {
  const _CountryPicker({required this.current});

  final Country current;

  @override
  State<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<_CountryPicker> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final q = _query.trim().toLowerCase().replaceFirst('+', '');
    final sorted = [...Country.all]..sort((a, b) => a.name.compareTo(b.name));
    final results = q.isEmpty
        ? sorted
        : sorted
              .where(
                (c) => c.name.toLowerCase().contains(q) || c.dial.startsWith(q),
              )
              .toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search country or code',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, i) {
                final c = results[i];
                final selected = c == widget.current;
                return ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(c.name),
                  trailing: Text(
                    '+${c.dial}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? colors.accent : colors.inkMuted,
                    ),
                  ),
                  selected: selected,
                  onTap: () => Navigator.of(context).pop(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
