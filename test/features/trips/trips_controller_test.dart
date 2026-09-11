import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/features/trips/trips_controller.dart';

import '../../support/fakes.dart';

void main() {
  late FakeBookingRepository bookings;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<TripsState>> keepAlive;

  setUp(() {
    bookings = FakeBookingRepository()
      ..pages = [
        [bookingWith(reference: 'SL-3'), bookingWith(reference: 'SL-2')],
        [bookingWith(reference: 'SL-1')],
      ];
    container = ProviderContainer.test(overrides: [bookingRepositoryProvider.overrideWithValue(bookings)]);
    // autoDispose: hold a listener the way the screen does.
    keepAlive = container.listen(tripsProvider, (_, _) {});
  });

  tearDown(() => keepAlive.close());

  test('loads the first page and knows there is more', () async {
    final state = await container.read(tripsProvider.future);

    expect(state.bookings.map((b) => b.reference), ['SL-3', 'SL-2']);
    expect(state.hasMore, isTrue);
    expect(bookings.pagesRequested, [1]);
  });

  test('load more appends the next page and stops at the last', () async {
    await container.read(tripsProvider.future);

    await container.read(tripsProvider.notifier).loadMore();

    final state = container.read(tripsProvider).requireValue;
    expect(state.bookings.map((b) => b.reference), ['SL-3', 'SL-2', 'SL-1']);
    expect(state.hasMore, isFalse);
    expect(state.isLoadingMore, isFalse);

    // Nothing left: a further call must not hit the network.
    await container.read(tripsProvider.notifier).loadMore();
    expect(bookings.pagesRequested, [1, 2]);
  });

  test('a failed page keeps what was loaded and exposes the error to retry', () async {
    bookings.pageError = const ApiException('You appear to be offline.');
    await container.read(tripsProvider.future);

    await container.read(tripsProvider.notifier).loadMore();

    final state = container.read(tripsProvider).requireValue;
    expect(state.bookings, hasLength(2));
    expect(state.loadMoreError, 'You appear to be offline.');
    expect(state.hasMore, isTrue);
  });

  test('invalidating reloads from the first page', () async {
    await container.read(tripsProvider.future);
    await container.read(tripsProvider.notifier).loadMore();

    container.invalidate(tripsProvider);
    final state = await container.read(tripsProvider.future);

    expect(state.bookings, hasLength(2));
    expect(bookings.pagesRequested, [1, 2, 1]);
  });

  test('upcoming and past are split from whatever is loaded', () async {
    bookings.pages = [
      [
        bookingWith(reference: 'FUTURE').copyWith(pickupAt: DateTime.now().add(const Duration(days: 3))),
        bookingWith(reference: 'DONE').copyWith(status: 'completed', pickupAt: DateTime.now().subtract(const Duration(days: 3))),
      ],
    ];
    container.invalidate(tripsProvider);

    final state = await container.read(tripsProvider.future);

    expect(state.upcoming.single.reference, 'FUTURE');
    expect(state.past.single.reference, 'DONE');
  });
}
