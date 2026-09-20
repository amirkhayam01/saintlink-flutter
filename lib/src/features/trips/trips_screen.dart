import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/inner_screen_header.dart';
import '../../widgets/route_timeline.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/tiles.dart';
import '../../domain/booking.dart';
import 'trips_controller.dart';
import '../auth/auth_controller.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(authControllerProvider).isSignedIn) {
      return const SizedBox.shrink();
    }
    final trips = ref.watch(tripsProvider);

    return Scaffold(
      appBar: InnerScreenHeader(
        title: 'My trips',
        showBack: false,
        background: InnerScreenHeader.brandBackground(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SegmentedTabs(
              labels: const ['Upcoming', 'Past'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: trips.when(
              loading: () => const TripListSkeleton(),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ErrorNotice(
                    error.toString(),
                    onRetry: () => ref.invalidate(tripsProvider),
                  ),
                ),
              ),
              data: (state) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _tab == 0
                    ? _TripList(
                        state.upcoming,
                        key: const ValueKey('upcoming'),
                        state: state,
                        emptyTitle: 'No upcoming trips',
                        emptyBody: 'Plan a journey and it will appear here, ready for the day.',
                      )
                    : _TripList(
                        state.past,
                        key: const ValueKey('past'),
                        state: state,
                        emptyTitle: 'No past trips yet',
                        emptyBody:
                            'Completed journeys stay here for your records.',
                      ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/book'),
        icon: const Icon(Icons.add),
        label: const Text('Plan a journey'),
      ),
    );
  }
}

class _TripList extends ConsumerWidget {
  const _TripList(
    this.bookings, {
    super.key,
    required this.state,
    required this.emptyTitle,
    required this.emptyBody,
  });

  final List<Booking> bookings;
  final TripsState state;
  final String emptyTitle;
  final String emptyBody;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(tripsProvider.future),
      child: bookings.isEmpty && !state.hasMore
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 64, 40, 40),
                  child: Column(
                    children: [
                      const IconDisc(Icons.receipt_long_outlined, size: 72),
                      const SizedBox(height: 18),
                      Text(
                        emptyTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        emptyBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.inkMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                for (final (i, booking) in bookings.indexed) ...[
                  if (_startsMonth(bookings, i))
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 4 : 18, bottom: 8),
                      child: GroupLabel(_monthLabel(booking)),
                    )
                  else
                    const SizedBox(height: 10),
                  _TripCard(booking),
                ],
                // One extra row at the end for the pager while there are pages left.
                if (state.hasMore)
                  _LoadMore(
                    isLoading: state.isLoadingMore,
                    error: state.loadMoreError,
                    onLoad: () => ref.read(tripsProvider.notifier).loadMore(),
                  ),
              ],
            ),
    );
  }
}

bool _startsMonth(List<Booking> bookings, int i) {
  if (i == 0) return true;
  final a = bookings[i - 1].pickupAt;
  final b = bookings[i].pickupAt;
  if (a == null || b == null) return a != b;
  return a.year != b.year || a.month != b.month;
}

String _monthLabel(Booking booking) {
  final when = booking.pickupAt;
  if (when == null) return 'Date to be confirmed';
  final now = DateTime.now();
  final month = Formatting.monthLong(when);
  return when.year == now.year ? month : '$month ${when.year}';
}

/// The last row of a list with more pages: fetches the next page as soon as
/// it scrolls into view, and falls back to a button if that fetch failed.
class _LoadMore extends StatefulWidget {
  const _LoadMore({
    required this.isLoading,
    required this.error,
    required this.onLoad,
  });

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
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard(this.booking);

  final Booking booking;

  /// "Today · 09:00", "Tomorrow · 09:00", else "Fri 25 Sep · 09:00".
  String _headline() {
    final when = booking.pickupAt;
    if (when == null) return booking.reference;
    final today = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(when);
    final date = day == today
        ? 'Today'
        : day == today.add(const Duration(days: 1))
        ? 'Tomorrow'
        : '${Formatting.weekday(when)} ${when.day} ${Formatting.monthShort(when)}';
    return '$date · ${Formatting.time(when)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Opacity(
      opacity: booking.isUpcoming ? 1 : 0.72,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/trips/${booking.reference}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _headline(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    StatusChip(
                      label: booking.statusLabel,
                      status: booking.status,
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, color: colors.inkMuted, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                RouteTimeline(
                  dense: true,
                  points: [
                    RoutePoint(address: booking.pickupAddress ?? ''),
                    RoutePoint(address: booking.dropoffAddress ?? ''),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: colors.inkFaint),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${booking.vehicle ?? ''}${booking.isReturn ? ' · return' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.reference,
                            style: TextStyle(
                              color: colors.inkMuted,
                              fontSize: 11,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatting.money(booking.totalAmount, booking.currency),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
