import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/inner_screen_header.dart';
import '../../widgets/vehicle_image.dart';
import 'booking_flow_controller.dart';
import 'booking_screen_header.dart';
import '../../domain/vehicle_category.dart';

/// Step two: pick a vehicle at a price that is already final.
///
/// Every fare shown here is held on the server against the quote token; the
/// app cannot alter it and does not send it back. What the customer taps is a
/// vehicle, and the server prices that vehicle from its own record.
class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // The quote lasts thirty minutes. A visible countdown is kinder than a
    // surprise refusal at the end of the passenger form.
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingFlowProvider);
    final controller = ref.read(bookingFlowProvider.notifier);
    final quote = state.quote;
    final journey = state.journey;

    if (quote == null) {
      return const Scaffold(body: Center(child: Text('No quote yet.')));
    }

    final expired = quote.hasExpired;
    final vehicles = state.availableVehicles;
    final selectedFits =
        state.selectedVehicle?.fits(
          passengers: journey.passengerCount,
          luggage: journey.luggageCount,
        ) ??
        false;

    final bestValue = state.suggestedVehicleSlug;

    return Scaffold(
      appBar: BookingScreenHeader(
        title: 'Choose your vehicle',
        journey: journey,
        expandable: true,
      ),
      body: expired
          ? _Expired(
              onRefresh: () async {
                if (await controller.requestQuote() && mounted) setState(() {});
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: vehicles.length + 1,
              separatorBuilder: (_, index) =>
                  SizedBox(height: index == 0 ? 16 : 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const BookingProgress(step: 1);
                }
                final vehicle = vehicles[index - 1];
                final fare = quote.fareFor(vehicle.slug)!;
                final fits = vehicle.fits(
                  passengers: journey.passengerCount,
                  luggage: journey.luggageCount,
                );
                final price = journey.isReturn ? fare.returnTotal : fare.single;

                return _VehicleCard(
                  vehicle: vehicle,
                  price: price,
                  fits: fits && price != null,
                  selected: journey.vehicleCategorySlug == vehicle.slug,
                  tag: vehicle.slug == bestValue ? 'Best value' : null,
                  onTap: () => controller.selectVehicle(vehicle.slug),
                );
              },
            ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: !expired && selectedFits && state.totalDue != null
              ? () => context.push('/book/details')
              : null,
          child: Text(
            state.totalDue == null || !selectedFits
                ? 'Select a vehicle'
                : 'Continue · ${Formatting.money(state.totalDue!)}',
          ),
        ),
      ),
    );
  }
}

/// One vehicle in the list.
///
/// The chosen one is shown in full — photo, capacities, the "best value"
/// tag — because that is the one the customer is about to pay for. The rest
/// fold to a single line of name and price, so the whole fleet fits on one
/// screen and choosing is a glance down a column of prices rather than a
/// scroll through five identical panels. Tapping a folded card opens it.
class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.price,
    required this.fits,
    required this.selected,
    required this.onTap,
    this.tag,
  });

  final VehicleCategory vehicle;
  final double? price;
  final bool fits;
  final bool selected;
  final String? tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget capacity(IconData icon, int count, String label) => Semantics(
      label: '$count $label',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.inkMuted),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(color: colors.inkMuted, fontSize: 13),
          ),
        ],
      ),
    );

    // Full when chosen, or when it cannot be chosen and has to say why.
    final open = selected || !fits;

    final tagPill = tag == null || !fits
        ? null
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tag!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colors.accent,
                height: 1.2,
              ),
            ),
          );

    return Opacity(
      opacity: fits ? 1 : 0.55,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? colors.tint : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.brand : colors.inkFaint,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: fits ? onTap : null,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(open ? 12 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(open ? 10 : 8),
                          child: SizedBox(
                            width: open ? 84 : 60,
                            height: open ? 56 : 40,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                VehicleImage(vehicle.slug),
                                if (selected)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colors.card,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: colors.accent,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vehicle.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              height: 1.25,
                                            ),
                                          ),
                                          // Folded, the tag still has to say
                                          // "best value" — it is the one thing
                                          // that helps someone pick.
                                          if (!open && tagPill != null) ...[
                                            const SizedBox(height: 4),
                                            tagPill,
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Price never wraps: shrink it instead when the
                                    // card is narrow or text is scaled up.
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth * 0.55,
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          price == null
                                              ? '—'
                                              : Formatting.money(price!),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            height: 1.2,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (open) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    capacity(
                                      Icons.person_outline,
                                      vehicle.passengerCapacity,
                                      'passengers',
                                    ),
                                    capacity(
                                      Icons.luggage_outlined,
                                      vehicle.luggageCapacity,
                                      'suitcases',
                                    ),
                                    if (vehicle.handLuggageCapacity > 0)
                                      capacity(
                                        Icons.shopping_bag_outlined,
                                        vehicle.handLuggageCapacity,
                                        'hand luggage items',
                                      ),
                                    ?tagPill,
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!fits) ...[
                      const SizedBox(height: 6),
                      Text(
                        price == null
                            ? 'Unavailable for this return journey'
                            : 'Not enough room for your party',
                        style: TextStyle(color: colors.inkMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Expired extends StatelessWidget {
  const _Expired({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_off_outlined,
              size: 48,
              color: context.colors.inkMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your quote has expired',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Prices are held for 30 minutes. Refresh to get a current price for the same journey.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.inkMuted),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRefresh,
              child: const Text('Refresh price'),
            ),
          ],
        ),
      ),
    );
  }
}
