import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
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

    if (quote == null) {
      return const Scaffold(body: Center(child: Text('No quote yet.')));
    }

    final expired = quote.hasExpired;
    final vehicles = state.availableVehicles;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your vehicle')),
      body: Column(
        children: [
          _QuoteBanner(quote: quote, isReturn: state.journey.isReturn),
          Expanded(
            child: expired
                ? _Expired(onRefresh: () async {
                    if (await controller.requestQuote()) setState(() {});
                  })
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: vehicles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      final fare = quote.fareFor(vehicle.slug)!;
                      final fits = vehicle.fits(passengers: state.journey.passengerCount, luggage: state.journey.luggageCount);
                      final price = state.journey.isReturn ? fare.returnTotal : fare.single;
                      final selected = state.journey.vehicleCategorySlug == vehicle.slug;

                      return _VehicleCard(
                        vehicle: vehicle,
                        price: price,
                        fits: fits && price != null,
                        selected: selected,
                        isReturn: state.journey.isReturn,
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
          child: Text(state.totalDue == null ? 'Select a vehicle' : 'Continue · ${Formatting.money(state.totalDue!)}'),
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

    return Container(
      width: double.infinity,
      color: AppTheme.midnight,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              parts.isEmpty ? 'Fixed price — no meter, no surprises' : parts.join(' · '),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Icon(Icons.timer_outlined, size: 16, color: quote.remaining.inMinutes < 5 ? AppTheme.brand : Colors.white54),
          const SizedBox(width: 4),
          Text(
            'Price held ${Formatting.countdown(quote.remaining)}',
            style: TextStyle(color: quote.remaining.inMinutes < 5 ? AppTheme.brand : Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
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
  });

  final VehicleCategory vehicle;
  final double? price;
  final bool fits;
  final bool selected;
  final bool isReturn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? AppTheme.midnight : context.colors.inkFaint, width: selected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: fits ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: selected ? AppTheme.brand : context.colors.surface, borderRadius: BorderRadius.circular(12)),
                child: Icon(_iconFor(vehicle.slug), color: context.colors.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.capacitySummary ?? '${vehicle.passengerCapacity} passengers · ${vehicle.luggageCapacity} large cases',
                      style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price == null ? '—' : Formatting.money(price!), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  if (isReturn && price != null) Text('return', style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  if (!fits) const Text('Too small', style: TextStyle(color: AppTheme.danger, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String slug) {
    if (slug.contains('minibus') || slug.contains('seater')) return Icons.airport_shuttle_outlined;
    if (slug.contains('mpv') || slug.contains('estate')) return Icons.directions_car_filled_outlined;
    if (slug.contains('executive') || slug.contains('luxury')) return Icons.star_outline;

    return Icons.directions_car_outlined;
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
