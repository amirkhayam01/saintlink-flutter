import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/auth/sign_in_screen.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/booking/details_screen.dart';
import 'package:saints_link/src/features/booking/journey_screen.dart';
import 'package:saints_link/src/features/booking/confirmation_screen.dart';
import 'package:saints_link/src/features/booking/vehicle_screen.dart';
import 'package:saints_link/src/features/trips/trip_detail_screen.dart';
import 'package:saints_link/src/features/trips/trips_screen.dart';
import 'package:saints_link/src/domain/booking.dart';

import '../support/fakes.dart';

/*
 * Renders each screen at iPhone-14-Pro size to test/screenshots/out/ as PNGs so a
 * design change can be looked at without a device. Real fonts are loaded —
 * the test binding's default renders text as blocks.
 *
 * Skipped in a normal `flutter test` run; render with:
 *   SCREENSHOTS=1 flutter test test/screenshots --update-goldens
 */
final render = Platform.environment['SCREENSHOTS'] == '1';

Future<void> loadFonts() async {
  final figtree = FontLoader('Figtree');
  for (final w in ['400', '500', '600', '700', '800']) {
    figtree.addFont(Future.value(ByteData.sublistView(File('assets/fonts/Figtree-$w.ttf').readAsBytesSync())));
  }
  await figtree.load();

  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '${Platform.environment['HOME']}/Development/flutter';
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf').readAsBytesSync())));
  await icons.load();
}

void main() {
  if (!render) return;


  final bookings = FakeBookingRepository()
    ..vehicles = fixtureVehicles()
    ..nextQuote = quoteExpiringIn(const Duration(minutes: 28));
  final auth = FakeAuthRepository()..hasSession = true;

  Booking sample(String ref, {int days = 4, bool paid = true}) => bookingWith(reference: ref, canPay: !paid).copyWith(
        status: paid ? 'confirmed' : 'awaiting_payment',
        statusLabel: paid ? 'Confirmed' : 'Awaiting payment',
        paymentStatus: paid ? 'paid' : 'unpaid',
        paymentStatusLabel: paid ? 'Paid' : 'Unpaid',
        journeyType: 'return',
        totalAmount: 310,
        pickupAt: DateTime.now().add(Duration(days: days, hours: 3)),
        pickupAddress: 'Southampton Central Station',
        dropoffAddress: 'Heathrow Airport Terminal 5',
        vehicle: 'Executive Saloon',
        customerName: 'Ada Lovelace',
        customerPhone: '07700 900000',
        customerEmail: 'ada@example.com',
        fareItems: const [FareItem(label: 'Outward journey', amount: 155), FareItem(label: 'Return journey', amount: 155)],
        legs: [
          BookingLeg(id: 1, direction: 'outbound', status: 'assigned', passengerCount: 2, largeLuggageCount: 1, includedWaitingMinutes: 45, meetAndGreet: true,
              pickupAt: DateTime.now().add(Duration(days: days, hours: 3)), requestedPickupAt: DateTime.now().add(Duration(days: days, hours: 2, minutes: 40)),
              vehicle: 'Executive Saloon', flight: const BookingFlight(number: 'BA123', terminal: 'T5', status: 'On time'),
              stops: const [BookingStop(type: 'pickup', address: 'Southampton Central Station'), BookingStop(type: 'dropoff', address: 'Heathrow Airport Terminal 5')]),
          BookingLeg(id: 2, direction: 'return', status: 'unassigned', passengerCount: 2, largeLuggageCount: 1, includedWaitingMinutes: 0, meetAndGreet: false,
              pickupAt: DateTime.now().add(Duration(days: days + 4, hours: 8)),
              stops: const [BookingStop(type: 'pickup', address: 'Heathrow Airport Terminal 5'), BookingStop(type: 'dropoff', address: 'Southampton Central Station')]),
        ],
      );

  ProviderContainer container() => ProviderContainer(overrides: [
        bookingRepositoryProvider.overrideWithValue(bookings),
        authRepositoryProvider.overrideWithValue(auth),
      ]);

  Future<void> shot(WidgetTester tester, String name, Widget home, {ThemeData? theme, Future<void> Function(ProviderContainer)? prime, bool tall = false}) async {
    await loadFonts();
    tester.view.physicalSize = Size(1179, tall ? 4400 : 2556);
    tester.view.devicePixelRatio = 3;
    final c = container();
    c.read(bookingFlowProvider);
    await tester.pump(); // lets the fleet load settle
    if (prime != null) await prime(c);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(theme: theme ?? AppTheme.light(), home: home, debugShowCheckedModeBanner: false),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    // Asset images only decode outside the fake-async zone.
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        await precacheImage((element.widget as Image).image, element);
      }
    });
    await tester.pump();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
    c.dispose();
  }

  Future<void> primeQuote(ProviderContainer c) async {
    c.read(bookingFlowProvider.notifier).updateJourney((_) => quotableJourney.copyWith(
          dropoff: const PlaceSelection(address: 'Heathrow Airport Terminal 5', placeId: 'h', latitude: 51.47, longitude: -0.49),
        ));
    await c.read(bookingFlowProvider.notifier).requestQuote();
    c.read(bookingFlowProvider.notifier).selectVehicle('executive-saloon');
  }

  testWidgets('home', (t) => shot(t, 'home', const JourneyScreen()));
  testWidgets('home dark', (t) => shot(t, 'home_dark', const JourneyScreen(), theme: AppTheme.dark(), tall: true));
  testWidgets('home full', (t) => shot(t, 'home_full', const JourneyScreen(), tall: true));
  testWidgets('home filled', (t) => shot(t, 'home_filled', const JourneyScreen(), prime: (c) async {
        c.read(bookingFlowProvider.notifier).updateJourney((_) => quotableJourney.copyWith(
              dropoff: const PlaceSelection(address: 'Heathrow Airport Terminal 5', placeId: 'h', latitude: 51.47, longitude: -0.49),
              isReturn: true,
              returnDate: DateTime(2026, 10, 5),
              returnTime: const TimeOfDay(hour: 14, minute: 0),
            ));
      }));
  testWidgets('vehicle', (t) => shot(t, 'vehicle', const VehicleScreen(), prime: primeQuote));
  testWidgets('details', (t) => shot(t, 'details', const DetailsScreen(), prime: primeQuote));
  testWidgets('sign in', (t) => shot(t, 'sign_in', const SignInScreen()));
  testWidgets('confirmation', (t) => shot(t, 'confirmation', const ConfirmationScreen(), prime: (c) async {
        await primeQuote(c);
        bookings.nextBooking = sample('SL-8K2M', paid: false);
        await c.read(bookingFlowProvider.notifier).confirmBooking(customerName: 'Ada Lovelace', customerPhone: '07700900000', customerEmail: 'ada@example.com');
      }));
  testWidgets('trips', (t) => shot(t, 'trips', const TripsScreen(), prime: (c) async {
        bookings.pages = [[sample('SL-8K2M'), sample('SL-7QPA', days: 12, paid: false), sample('SL-2BXA', days: -20)]];
      }));
  testWidgets('trip detail', (t) => shot(t, 'trip_detail', const TripDetailScreen(reference: 'SL-8K2M'), prime: (c) async {
        bookings.nextBooking = sample('SL-8K2M');
      }));
}
