import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/vehicle_image.dart';
import 'booking_flow_controller.dart';
import '../../domain/quote.dart';
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
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
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

    // The cheapest vehicle that fits is worth pointing out; nothing else here
    // is a recommendation we could stand behind without data.
    String? bestValue;
    double? bestPrice;
    for (final v in vehicles) {
      final price = journey.isReturn ? quote.fareFor(v.slug)?.returnTotal : quote.fareFor(v.slug)?.single;
      if (price != null && v.fits(passengers: journey.passengerCount, luggage: journey.luggageCount) && (bestPrice == null || price < bestPrice)) {
        bestPrice = price;
        bestValue = v.slug;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your vehicle'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StepIndicator(step: 1),
                const SizedBox(height: 12),
                RouteSummary(
                  from: journey.pickup.address,
                  to: journey.dropoff.address,
                  subtitle: journey.pickupDate == null || journey.pickupTime == null
                      ? null
                      : '${Formatting.date(journey.pickupDate!)} · ${MaterialLocalizations.of(context).formatTimeOfDay(journey.pickupTime!, alwaysUse24HourFormat: true)}${journey.isReturn ? ' · return' : ''}',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _QuoteBanner(quote: quote, isReturn: journey.isReturn),
          Expanded(
            child: expired
                ? _Expired(onRefresh: () async {
                    if (await controller.requestQuote()) setState(() {});
                  })
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    itemCount: vehicles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      final fare = quote.fareFor(vehicle.slug)!;
                      final fits = vehicle.fits(passengers: journey.passengerCount, luggage: journey.luggageCount);
                      final price = journey.isReturn ? fare.returnTotal : fare.single;

                      return _VehicleCard(
                        vehicle: vehicle,
                        price: price,
                        fits: fits && price != null,
                        selected: journey.vehicleCategorySlug == vehicle.slug,
                        isReturn: journey.isReturn,
                        tag: vehicle.slug == bestValue ? 'Best value' : null,
                        onTap: () => controller.selectVehicle(vehicle.slug),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: !expired && state.selectedVehicle != null && state.totalDue != null
              ? () => context.push('/book/details')
              : null,
          child: Text(state.totalDue == null ? 'Select a vehicle' : 'Continue with ${state.selectedVehicle!.name} · ${Formatting.money(state.totalDue!)}'),
        ),
      ),
    );
  }
}

class _QuoteBanner extends StatelessWidget {
  const _QuoteBanner({required this.quote, required this.isReturn});

  final Quote quote;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (quote.distanceMiles != null) Formatting.miles(quote.distanceMiles!),
      if (quote.estimatedDurationMinutes != null) 'about ${Formatting.duration(quote.estimatedDurationMinutes!)}',
      if (isReturn) 'each way',
    ];
    final urgent = quote.remaining.inMinutes < 5;

    return Container(
      width: double.infinity,
      color: AppTheme.midnight,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.route_outlined, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parts.isEmpty ? 'Fixed price — no meter, no surprises' : parts.join(' · '),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: urgent ? AppTheme.brand : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: urgent ? AppTheme.midnight : Colors.white),
                const SizedBox(width: 5),
                Text(
                  'Held ${Formatting.countdown(quote.remaining)}',
                  style: TextStyle(color: urgent ? AppTheme.midnight : Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.price,
    required this.fits,
    required this.selected,
    required this.isReturn,
    required this.onTap,
    this.tag,
  });

  final VehicleCategory vehicle;
  final double? price;
  final bool fits;
  final bool selected;
  final bool isReturn;
  final String? tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Opacity(
      opacity: fits ? 1 : 0.55,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? AppTheme.brand : colors.inkFaint, width: selected ? 2 : 1),
          boxShadow: selected ? colors.floatingShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: fits ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(width: 104, height: 72, child: VehicleImage(vehicle.slug)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tag != null && fits)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.brand, borderRadius: BorderRadius.circular(6)),
                              child: Text(tag!.toUpperCase(), style: const TextStyle(color: AppTheme.midnight, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                            ),
                          ),
                        Text(vehicle.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 15, color: colors.inkMuted),
                            Text(' ${vehicle.passengerCapacity}', style: TextStyle(color: colors.inkMuted, fontSize: 13)),
                            const SizedBox(width: 10),
                            Icon(Icons.luggage_outlined, size: 15, color: colors.inkMuted),
                            Text(' ${vehicle.luggageCapacity}', style: TextStyle(color: colors.inkMuted, fontSize: 13)),
                            if (vehicle.handLuggageCapacity > 0) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.shopping_bag_outlined, size: 15, color: colors.inkMuted),
                              Text(' ${vehicle.handLuggageCapacity}', style: TextStyle(color: colors.inkMuted, fontSize: 13)),
                            ],
                          ],
                        ),
                        if (!fits) ...[
                          const SizedBox(height: 4),
                          Text('Not enough room for your party', style: TextStyle(color: colors.inkMuted, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(price == null ? '—' : Formatting.money(price!), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.3)),
                      Text(isReturn ? 'return' : 'fixed', style: TextStyle(color: colors.inkMuted, fontSize: 11)),
                    ],
                  ),
                ],
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_off_outlined, size: 48, color: context.colors.inkMuted),
            const SizedBox(height: 12),
            const Text('Your quote has expired', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 6),
            Text('Prices are held for 30 minutes. Refresh to get a current price for the same journey.', textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted)),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRefresh, child: const Text('Refresh price')),
          ],
        ),
      ),
    );
  }
}
