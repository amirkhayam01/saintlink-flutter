import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import 'booking_models.dart';
import 'trips_controller.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final trips = ref.watch(tripsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My trips'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'signout') {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go('/');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(enabled: false, child: Text(auth.customer?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                const PopupMenuItem(value: 'signout', child: Text('Sign out')),
              ],
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past')]),
        ),
        body: trips.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorNotice(error.toString(), onRetry: () => ref.invalidate(tripsProvider)),
            ),
          ),
          data: (bookings) => TabBarView(
            children: [
              _TripList(bookings.where((b) => b.isUpcoming).toList(), empty: 'No upcoming trips. Book one and it will appear here.', onRefresh: () => ref.refresh(tripsProvider.future)),
              _TripList(bookings.where((b) => !b.isUpcoming).toList(), empty: 'No past trips yet.', onRefresh: () => ref.refresh(tripsProvider.future)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/'),
          backgroundColor: AppTheme.brand,
          foregroundColor: AppTheme.midnight,
          icon: const Icon(Icons.add),
          label: const Text('Book'),
        ),
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  const _TripList(this.bookings, {required this.empty, required this.onRefresh});

  final List<Booking> bookings;
  final String empty;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: bookings.isEmpty
          ? ListView(children: [Padding(padding: const EdgeInsets.all(40), child: Text(empty, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.inkMuted)))])
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _TripCard(bookings[index]),
            ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard(this.booking);

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/trips/${booking.reference}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(booking.pickupAt == null ? booking.reference : Formatting.dateAndTime(booking.pickupAt!), style: const TextStyle(fontWeight: FontWeight.w700))),
                  StatusChip(label: booking.statusLabel, status: booking.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(booking.pickupAddress ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(
                children: [
                  const Icon(Icons.arrow_downward, size: 14, color: AppTheme.inkMuted),
                  const SizedBox(width: 4),
                  Expanded(child: Text(booking.dropoffAddress ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('${booking.vehicle ?? ''}${booking.isReturn ? ' · return' : ''}', style: const TextStyle(color: AppTheme.inkMuted, fontSize: 13))),
                  Text(Formatting.money(booking.totalAmount, booking.currency), style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (booking.canPay) ...[
                    const SizedBox(width: 8),
                    const Text('Unpaid', style: TextStyle(color: AppTheme.brandDark, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
