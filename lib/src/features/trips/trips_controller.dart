import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../domain/booking.dart';
import '../../domain/page_meta.dart';

part 'trips_controller.freezed.dart';

@freezed
abstract class TripsState with _$TripsState {
  const TripsState._();

  const factory TripsState({
    required List<Booking> bookings,
    required PageMeta page,
    @Default(false) bool isLoadingMore,
    String? loadMoreError,
  }) = _TripsState;

  bool get hasMore => page.hasMore;

  // Split into tabs here; the server lists newest first, so an old booking for a future date can be on a later page.
  List<Booking> get upcoming => bookings.where((b) => b.isUpcoming).toList();

  List<Booking> get past => bookings.where((b) => !b.isUpcoming).toList();
}

/// The customer's bookings, a page at a time. Invalidate to reload; [loadMore] appends.
class TripsController extends AsyncNotifier<TripsState> {
  @override
  Future<TripsState> build() async {
    final first = await ref.read(bookingRepositoryProvider).myBookings();

    return TripsState(bookings: first.items, page: first.meta);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreError: null),
    );

    try {
      final next = await ref
          .read(bookingRepositoryProvider)
          .myBookings(page: current.page.currentPage + 1);

      state = AsyncData(
        current.copyWith(
          bookings: [...current.bookings, ...next.items],
          page: next.meta,
          isLoadingMore: false,
        ),
      );
    } on ApiException catch (error) {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error.message),
      );
    }
  }
}

final tripsProvider =
    AsyncNotifierProvider.autoDispose<TripsController, TripsState>(
      TripsController.new,
    );

final tripDetailProvider = FutureProvider.autoDispose.family<Booking, String>((
  ref,
  reference,
) {
  return ref.watch(bookingRepositoryProvider).booking(reference);
});
