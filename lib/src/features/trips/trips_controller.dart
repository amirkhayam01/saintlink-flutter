import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'booking_models.dart';

/// The signed-in customer's bookings, refetched whenever invalidated.
final tripsProvider = FutureProvider.autoDispose<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).myBookings();
});

final tripDetailProvider = FutureProvider.autoDispose.family<Booking, String>((ref, reference) {
  return ref.watch(bookingRepositoryProvider).booking(reference);
});
