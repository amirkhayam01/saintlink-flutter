import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';
import 'recent_places.dart';

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
    _finish(selection);
  }

  void _finish(PlaceSelection selection) {
    ref.read(recentPlacesProvider.notifier).remember(selection);
    Navigator.of(context).pop(selection);
  }

  void _useTypedText() {
    Navigator.of(context).pop(PlaceSelection(address: _controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final typed = _controller.text.trim();
    final colors = context.colors;
    final recents = ref.watch(recentPlacesProvider).value ?? const <PlaceSelection>[];
    final browsing = typed.length < 3;

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
              onChanged: (text) {
                setState(() {});
                _onChanged(text);
              },
              onSubmitted: (_) => typed.isEmpty ? null : _useTypedText(),
              decoration: InputDecoration(
                hintText: 'Address, postcode, airport or port',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                    : (typed.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { _controller.clear(); setState(() {}); _onChanged(''); })),
              ),
            ),
          ),
          if (_searchUnavailable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('Suggestions are unavailable right now. You can still continue with the address as typed.', style: TextStyle(color: colors.inkMuted, fontSize: 13)),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (browsing) ...[
                  _Heading('Airports and ports'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final place in shortcutPlaces)
                          ActionChip(
                            avatar: Icon(place.address.contains('Cruise') ? Icons.directions_boat_outlined : Icons.flight_takeoff, size: 16, color: colors.ink),
                            label: Text(place.address),
                            labelStyle: TextStyle(color: colors.ink, fontWeight: FontWeight.w600, fontSize: 13),
                            backgroundColor: colors.card,
                            side: BorderSide(color: colors.inkFaint),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            onPressed: () => _finish(place),
                          ),
                      ],
                    ),
                  ),
                  if (recents.isNotEmpty) ...[
                    _Heading('Recent'),
                    for (final place in recents)
                      _PlaceRow(icon: Icons.history, title: place.address, onTap: () => _finish(place)),
                  ],
                ] else ...[
                  for (final suggestion in _suggestions)
                    _PlaceRow(icon: Icons.place_outlined, title: suggestion.description, onTap: () => _choose(suggestion)),
                  if (_suggestions.isEmpty && !_searching && !_searchUnavailable)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text('No matches yet — keep typing, or use the address as written.', style: TextStyle(color: colors.inkMuted, fontSize: 13)),
                    ),
                  _PlaceRow(
                    icon: Icons.keyboard_outlined,
                    title: 'Use "$typed"',
                    subtitle: 'As typed, without a map location',
                    muted: true,
                    onTap: _useTypedText,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(text.toUpperCase(), style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({required this.icon, required this.title, required this.onTap, this.subtitle, this.muted = false});

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.inkFaint)),
              child: Icon(icon, size: 18, color: colors.inkMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: muted ? FontWeight.w500 : FontWeight.w600, color: muted ? colors.inkMuted : colors.ink)),
                  if (subtitle != null) Text(subtitle!, style: TextStyle(color: colors.inkMuted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
