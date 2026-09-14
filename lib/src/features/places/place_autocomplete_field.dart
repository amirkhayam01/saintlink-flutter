import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';

/// An inline destination search backed by the website's Google Places proxy.
class PlaceAutocompleteField extends ConsumerStatefulWidget {
  const PlaceAutocompleteField({super.key, required this.onSelected});

  final ValueChanged<PlaceSelection> onSelected;

  @override
  ConsumerState<PlaceAutocompleteField> createState() =>
      _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState
    extends ConsumerState<PlaceAutocompleteField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  int _revision = 0;
  List<PlaceSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _resolving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  void _focusChanged() => setState(() {});

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.removeListener(_focusChanged);
    _focus.dispose();
    super.dispose();
  }

  void _changed(String value) {
    _debounce?.cancel();
    final revision = ++_revision;
    final query = value.trim();
    setState(() {
      _suggestions = const [];
      _error = null;
      _searching = query.length >= 3;
    });
    if (query.length < 3) return;
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _search(query, revision),
    );
  }

  Future<void> _search(String query, int revision) async {
    try {
      final suggestions = await ref
          .read(placesRepositoryProvider)
          .search(query);
      if (!mounted || revision != _revision) return;
      setState(() => _suggestions = suggestions.take(5).toList());
    } catch (_) {
      if (!mounted || revision != _revision) return;
      setState(
        () => _error = 'Address search is unavailable. Please try again.',
      );
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
      _error = null;
    });
    try {
      final place = await ref
          .read(placesRepositoryProvider)
          .resolve(suggestion);
      if (!mounted) return;
      _focus.unfocus();
      _controller.clear();
      setState(() => _suggestions = const []);
      widget.onSelected(place);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = error is ApiException
            ? error.message
            : 'Unable to select this address. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inputTheme = Theme.of(context).inputDecorationTheme;
    InputBorder rounded(InputBorder? border) =>
        (border is OutlineInputBorder ? border : const OutlineInputBorder())
            .copyWith(borderRadius: BorderRadius.circular(999));
    final showResults = _focus.hasFocus && _controller.text.trim().length >= 3;
    return TextFieldTapRegion(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focus,
            readOnly: _resolving,
            maxLength: 200,
            textInputAction: TextInputAction.search,
            onChanged: _changed,
            decoration: InputDecoration(
              border: rounded(inputTheme.border),
              enabledBorder: rounded(inputTheme.enabledBorder),
              focusedBorder: rounded(inputTheme.focusedBorder),
              errorBorder: rounded(inputTheme.errorBorder),
              focusedErrorBorder: rounded(inputTheme.focusedErrorBorder),
              hintText: 'Where can we take you?',
              counterText: '',
              prefixIcon: Icon(Icons.search_rounded, color: colors.accent),
              suffixIcon: _searching || _resolving
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear destination',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _controller.clear();
                        _changed('');
                      },
                    ),
            ),
          ),
          if (showResults) ...[
            const SizedBox(height: 4),
            Material(
              color: colors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.inkFaint),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final suggestion in _suggestions)
                    ListTile(
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: colors.inkMuted,
                      ),
                      title: Text(
                        suggestion.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.north_west_rounded, size: 16),
                      onTap: _resolving ? null : () => _choose(suggestion),
                    ),
                  if (_error != null ||
                      (!_searching && !_resolving && _suggestions.isEmpty))
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error ?? 'No places found. Try an address, postcode or airport.',
                        style: TextStyle(fontSize: 13, color: colors.inkMuted),
                      ),
                    ),
                  if (_error != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _resolving
                            ? null
                            : () => _changed(_controller.text),
                        child: const Text('Try again'),
                      ),
                    ),
                  if (_suggestions.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
