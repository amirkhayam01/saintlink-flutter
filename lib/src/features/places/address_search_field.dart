import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../booking/journey_draft.dart';
import '../booking/models.dart';

/// A field that opens a full-screen address search.
///
/// A full screen rather than an inline dropdown: on a phone the keyboard takes
/// half the screen, and a suggestion list squeezed into the remaining space
/// under a form field is the single most common place a booking is abandoned.
class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon = Icons.place_outlined,
  });

  final String label;
  final PlaceSelection value;
  final ValueChanged<PlaceSelection> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final selection = await Navigator.of(context).push<PlaceSelection>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => AddressSearchScreen(title: label, initial: value),
          ),
        );

        if (selection != null) onChanged(selection);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: value.isEmpty
              ? null
              : Icon(
                  value.isLocated ? Icons.check_circle : Icons.info_outline,
                  color: value.isLocated ? AppTheme.success : AppTheme.brandDark,
                ),
        ),
        isEmpty: value.isEmpty,
        child: Text(value.address, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class AddressSearchScreen extends ConsumerStatefulWidget {
  const AddressSearchScreen({super.key, required this.title, required this.initial});

  final String title;
  final PlaceSelection initial;

  @override
  ConsumerState<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends ConsumerState<AddressSearchScreen> {
  late final TextEditingController _controller;
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _searchUnavailable = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial.address);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Debounced: every keystroke is a billed lookup on the server, and a
  /// customer typing "Southampton Airport" does not need eighteen of them.
  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(text));
  }

  Future<void> _search(String text) async {
    if (text.trim().length < 3) {
      setState(() => _suggestions = const []);

      return;
    }

    setState(() => _searching = true);

    try {
      final results = await ref.read(placesRepositoryProvider).search(text);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searchUnavailable = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Search being down must not block a booking: the typed text is still
      // usable, and the server can price known places from text alone.
      setState(() => _searchUnavailable = true);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _choose(PlaceSuggestion suggestion) async {
    final selection = await ref.read(placesRepositoryProvider).resolve(suggestion);
    if (!mounted) return;
    Navigator.of(context).pop(selection);
  }

  void _useTypedText() {
    Navigator.of(context).pop(PlaceSelection(address: _controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final typed = _controller.text.trim();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (_) => typed.isEmpty ? null : _useTypedText(),
              decoration: InputDecoration(
                hintText: 'Address, postcode, airport or port',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                    : (typed.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { _controller.clear(); _onChanged(''); })),
              ),
            ),
          ),
          if (_searchUnavailable)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('Suggestions are unavailable right now. You can still continue with the address as typed.', style: TextStyle(color: AppTheme.inkMuted, fontSize: 13)),
            ),
          Expanded(
            child: ListView(
              children: [
                for (final suggestion in _suggestions)
                  ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(suggestion.description),
                    onTap: () => _choose(suggestion),
                  ),
                if (typed.length >= 3)
                  ListTile(
                    leading: const Icon(Icons.keyboard_outlined, color: AppTheme.inkMuted),
                    title: Text('Use "$typed"'),
                    subtitle: const Text('As typed, without a map location', style: TextStyle(fontSize: 12)),
                    onTap: _useTypedText,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
