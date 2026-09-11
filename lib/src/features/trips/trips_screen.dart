import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import '../../domain/booking.dart';
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
                switch (value) {
                  case 'profile':
                    context.push('/profile');
                  case 'signout':
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) context.go('/');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(enabled: false, child: Text(auth.customer?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                const PopupMenuItem(value: 'profile', child: Text('Your details')),
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
          data: (state) => TabBarView(
            children: [
              _TripList(state.upcoming, state: state, empty: 'No upcoming trips. Book one and it will appear here.'),
              _TripList(state.past, state: state, empty: 'No past trips yet.'),
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

class _TripList extends ConsumerWidget {
  const _TripList(this.bookings, {required this.state, required this.empty});

  final List<Booking> bookings;
  final TripsState state;
  final String empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(tripsProvider.future),
      child: bookings.isEmpty && !state.hasMore
          ? ListView(children: [Padding(padding: const EdgeInsets.all(40), child: Text(empty, textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted)))])
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              // One extra row at the end for the pager while there are pages left.
              itemCount: bookings.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => index < bookings.length
                  ? _TripCard(bookings[index])
                  : _LoadMore(
                      isLoading: state.isLoadingMore,
                      error: state.loadMoreError,
                      onLoad: () => ref.read(tripsProvider.notifier).loadMore(),
                    ),
            ),
    );
  }
}

/// The last row of a list with more pages: fetches the next page as soon as
/// it scrolls into view, and falls back to a button if that fetch failed.
class _LoadMore extends StatefulWidget {
  const _LoadMore({required this.isLoading, required this.error, required this.onLoad});

  final bool isLoading;
  final String? error;
  final VoidCallback onLoad;

  @override
  State<_LoadMore> createState() => _LoadMoreState();
}

class _LoadMoreState extends State<_LoadMore> {
  @override
  void initState() {
    super.initState();
    if (!widget.isLoading && widget.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onLoad());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.error != null) {
      return ErrorNotice(widget.error!, onRetry: widget.onLoad);
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))),
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
                  Icon(Icons.arrow_downward, size: 14, color: context.colors.inkMuted),
                  const SizedBox(width: 4),
                  Expanded(child: Text(booking.dropoffAddress ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('${booking.vehicle ?? ''}${booking.isReturn ? ' · return' : ''}', style: TextStyle(color: context.colors.inkMuted, fontSize: 13))),
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
