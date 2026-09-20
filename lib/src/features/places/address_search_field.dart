import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/api_exception.dart';
import '../../widgets/inner_screen_header.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';
import 'current_location.dart';
import 'recent_places.dart';

/// Open address selection above the booking form, keeping the keyboard clear.
Future<PlaceSelection?> showAddressSearchSheet(
  BuildContext context, {
  required String title,
  PlaceSelection initial = PlaceSelection.empty,
  bool allowCurrentLocation = false,
}) {
  return showModalBottomSheet<PlaceSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: context.colors.surface,
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (context) {
      final keyboard = MediaQuery.viewInsetsOf(context).bottom;
      final available =
          (MediaQuery.sizeOf(context).height -
                  keyboard -
                  MediaQuery.viewPaddingOf(context).top -
                  48)
              .clamp(0.0, double.infinity);
      return Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SizedBox(
          height: available * 0.9,
          child: AddressSearchScreen(
            title: title,
            initial: initial,
            isBottomSheet: true,
            allowCurrentLocation: allowCurrentLocation,
          ),
        ),
      );
    },
  );
}

/// An address field that opens the shared search sheet.
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
        final selection = await showAddressSearchSheet(
          context,
          title: label,
          initial: value,
        );

        if (selection != null && context.mounted) onChanged(selection);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: value.isEmpty
              ? null
              : Icon(
                  value.isLocated ? Icons.check_circle : Icons.info_outline,
                  color: value.isLocated
                      ? AppTheme.success
                      : context.colors.accent,
                ),
        ),
        isEmpty: value.isEmpty,
        child: Text(
          value.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class AddressSearchScreen extends ConsumerStatefulWidget {
  const AddressSearchScreen({
    super.key,
    required this.title,
    required this.initial,
    this.isBottomSheet = false,
    this.allowCurrentLocation = false,
  });

  final String title;
  final PlaceSelection initial;
  final bool isBottomSheet;

  /// Offer "use my current location". On for the pickup field only: where the
  /// customer is standing is a likely pickup and an unlikely destination.
  final bool allowCurrentLocation;

  @override
  ConsumerState<AddressSearchScreen> createState() =>
      _AddressSearchScreenState();
}

class _AddressSearchScreenState extends ConsumerState<AddressSearchScreen> {
  late final TextEditingController _controller;
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _resolving = false;
  int _revision = 0;
  bool _searchUnavailable = false;
  String? _selectionError;
  bool _locating = false;

  /// Set when the permission can no longer be asked for in-app, so the error
  /// line grows an "Open settings" action instead of a dead end.
  bool _offerSettings = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial.address);
    if (widget.initial.address.trim().length >= 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onChanged(_controller.text);
      });
    }
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
    final revision = ++_revision;
    setState(() {
      _suggestions = const [];
      _searchUnavailable = false;
      _selectionError = null;
      _searching = text.trim().length >= 3;
    });
    if (!_searching) return;
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _search(text, revision),
    );
  }

  Future<void> _search(String text, int revision) async {
    try {
      final results = await ref.read(placesRepositoryProvider).search(text);
      if (!mounted || revision != _revision) return;
      setState(() => _suggestions = results);
    } catch (_) {
      if (!mounted || revision != _revision) return;
      setState(() => _searchUnavailable = true);
    } finally {
      if (mounted && revision == _revision) setState(() => _searching = false);
    }
  }

  Future<void> _choose(PlaceSuggestion suggestion) async {
    if (_resolving) return;
    _debounce?.cancel();
    ++_revision;
    setState(() {
      _resolving = true;
      _searching = false;
    });
    try {
      final selection = await ref
          .read(placesRepositoryProvider)
          .resolve(suggestion);
      if (!mounted) return;
      _finish(selection);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _selectionError = error is ApiException
            ? error.message
            : 'Unable to select this address. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  /*
   * Two steps, and either can fail for a reason the customer can act on: the
   * phone has to produce a fix, then the server has to name it. The prompt
   * for permission happens inside the first step, on this tap and not
   * before — a request at launch is the one most people refuse.
   */
  Future<void> _useCurrentLocation() async {
    if (_locating || _resolving) return;
    _debounce?.cancel();
    ++_revision;
    setState(() {
      _locating = true;
      _searching = false;
      _selectionError = null;
      _offerSettings = false;
    });

    try {
      final fix = await ref.read(locationSourceProvider).current();
      ref.invalidate(locationGrantedProvider);
      final selection = await ref
          .read(placesRepositoryProvider)
          .reverse(latitude: fix.latitude, longitude: fix.longitude);
      if (!mounted) return;
      _finish(selection);
    } on LocationDeniedException catch (error) {
      if (!mounted) return;
      setState(() {
        _offerSettings = error.denial == LocationDenial.deniedForever;
        _selectionError = switch (error.denial) {
          LocationDenial.servicesOff =>
            'Location is switched off on this device. Turn it on, or search for your address instead.',
          LocationDenial.denied =>
            'We need your permission to use your location. You can search for your address instead.',
          LocationDenial.deniedForever =>
            'Location access is off for Saints Link. You can turn it on in Settings, or search for your address instead.',
          LocationDenial.unavailable =>
            'We could not find your location just now. Please try again, or search for your address instead.',
        };
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _selectionError = error is ApiException
            ? error.message
            : 'We could not find an address at your location. Please search for it instead.',
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _finish(PlaceSelection selection) {
    ref.read(recentPlacesProvider.notifier).remember(selection);
    Navigator.of(context).pop(selection);
  }

  void _useTypedText() {
    if (_resolving) return;
    Navigator.of(context).pop(PlaceSelection(address: _controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final typed = _controller.text.trim();
    final colors = context.colors;
    final recents = ref.watch(goAgainPlacesProvider);
    final browsing = typed.length < 3;

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextField(
            controller: _controller,
            autofocus: true,
            readOnly: _resolving,
            maxLength: 200,
            textInputAction: TextInputAction.search,
            onChanged: (text) {
              setState(() {});
              _onChanged(text);
            },
            onSubmitted: (_) =>
                typed.isEmpty || _resolving ? null : _useTypedText(),
            decoration: InputDecoration(
              hintText: 'Address, postcode, airport or port',
              counterText: '',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searching || _resolving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (typed.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() {});
                              _onChanged('');
                            },
                          )),
            ),
          ),
        ),
        if (_searchUnavailable)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Suggestions are unavailable right now. You can still continue with the address as typed.',
              style: TextStyle(color: colors.inkMuted, fontSize: 13),
            ),
          ),
        if (_selectionError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectionError!,
                    style: TextStyle(fontSize: 13, color: colors.inkMuted),
                  ),
                  if (_offerSettings)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () =>
                            ref.read(locationSourceProvider).openSettings(),
                        child: const Text('Open settings'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (browsing) ...[
                if (widget.allowCurrentLocation)
                  _PlaceRow(
                    icon: Icons.my_location_rounded,
                    title: 'Use my current location',
                    subtitle: _locating ? 'Finding your address…' : null,
                    onTap: _useCurrentLocation,
                  ),
                _Heading('Airports and ports'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final place in shortcutPlaces)
                        ActionChip(
                          avatar: Icon(
                            place.address.contains('Cruise')
                                ? Icons.directions_boat_outlined
                                : Icons.flight_takeoff,
                            size: 16,
                            color: colors.ink,
                          ),
                          label: Text(place.address),
                          labelStyle: TextStyle(
                            color: colors.ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          backgroundColor: colors.card,
                          side: BorderSide(color: colors.inkFaint),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          onPressed: () => _finish(place),
                        ),
                    ],
                  ),
                ),
                if (recents.isNotEmpty) ...[
                  _Heading('Recent'),
                  for (final place in recents)
                    _PlaceRow(
                      icon: Icons.history,
                      title: place.address,
                      onTap: () => _finish(place),
                    ),
                ],
              ] else ...[
                for (final suggestion in _suggestions)
                  _PlaceRow(
                    icon: Icons.place_outlined,
                    title: suggestion.description,
                    onTap: () {
                      if (!_resolving) _choose(suggestion);
                    },
                  ),
                if (_suggestions.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Google Maps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                if (_suggestions.isEmpty && !_searching && !_searchUnavailable)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'No matches yet — keep typing, or use the address as written.',
                      style: TextStyle(color: colors.inkMuted, fontSize: 13),
                    ),
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
    );
    if (widget.isBottomSheet) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close address search',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }
    return Scaffold(
      appBar: InnerScreenHeader(title: widget.title),
      body: body,
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
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.colors.inkMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.muted = false,
  });

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
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.inkFaint),
              ),
              child: Icon(icon, size: 18, color: colors.inkMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: muted ? FontWeight.w500 : FontWeight.w600,
                      color: muted ? colors.inkMuted : colors.ink,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(color: colors.inkMuted, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
