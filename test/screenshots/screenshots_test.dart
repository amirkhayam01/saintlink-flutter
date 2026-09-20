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
import 'package:saints_link/src/features/booking/journey_date_time_sheet.dart';
import 'package:saints_link/src/features/booking/confirmation_screen.dart';
import 'package:saints_link/src/features/booking/vehicle_screen.dart';
import 'package:saints_link/src/features/trips/trip_detail_screen.dart';
import 'package:saints_link/src/features/trips/trips_screen.dart';
import 'package:saints_link/src/features/home/home_screen.dart';
import 'package:saints_link/src/features/places/address_search_field.dart';
import 'package:saints_link/src/features/places/recent_places.dart';
import 'package:saints_link/src/features/profile/profile_screen.dart';
import 'package:saints_link/src/features/services/prices_screen.dart';
import 'package:saints_link/src/features/services/service_screen.dart';
import 'package:saints_link/src/features/auth/auth_controller.dart';
import 'package:saints_link/src/domain/booking.dart';
import 'package:saints_link/src/widgets/app_shell.dart';

import '../support/fakes.dart';
import '../support/platform_views.dart';

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

  ProviderContainer container({RecentPlaces Function()? recents}) => ProviderContainer(overrides: [
        bookingRepositoryProvider.overrideWithValue(bookings),
        authRepositoryProvider.overrideWithValue(auth),
        // The session is faked but the API client is real: without this the
        // signed-in home would fire a live request whose timeout outlives the test.
        customerPlacesProvider.overrideWith((ref) async => const <PlaceSelection>[]),
        if (recents != null) recentPlacesProvider.overrideWith(recents),
      ]);

  Future<void> shot(WidgetTester tester, String name, Widget home, {ThemeData? theme, Future<void> Function(ProviderContainer)? prime, bool tall = false, RecentPlaces Function()? recents, Future<void> Function(WidgetTester)? act}) async {
    stubPlatformViews();
    // flutter_test draws elevation as a solid black outline unless told
    // otherwise; these pictures exist to be looked at, so shadows are real.
    debugDisableShadows = false;
    await loadFonts();
    tester.view.physicalSize = Size(1179, tall ? 4400 : 2556);
    tester.view.devicePixelRatio = 3;
    final c = container(recents: recents);
    c.read(bookingFlowProvider);
    await tester.pump(); // lets the fleet load settle
    if (prime != null) await prime(c);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(theme: theme ?? AppTheme.light(), home: home, debugShowCheckedModeBanner: false),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    if (act != null) {
      await act(tester);
      await tester.pumpAndSettle();
    }
    // Asset images only decode outside the fake-async zone.
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        await precacheImage((element.widget as Image).image, element);
      }
    });
    await tester.pump();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
    // Back before the framework checks that no painting flag leaked out of the test.
    debugDisableShadows = true;
    c.dispose();
  }

  Future<void> primeQuote(ProviderContainer c) async {
    c.read(bookingFlowProvider.notifier).updateJourney((_) => quotableJourney.copyWith(
          dropoff: const PlaceSelection(address: 'Heathrow Airport Terminal 5', placeId: 'h', latitude: 51.47, longitude: -0.49),
        ));
    await c.read(bookingFlowProvider.notifier).requestQuote();
    c.read(bookingFlowProvider.notifier).selectVehicle('executive-saloon');
  }

  testWidgets('home full', (t) => shot(t, 'home_full', const JourneyScreen(), tall: true));
  testWidgets('home', (t) => shot(
        t,
        'home',
        Scaffold(
          body: const HomeScreen(),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
        tall: true,
      ));
  testWidgets('home with recents', (t) => shot(
        t,
        'home_recents',
        Scaffold(
          body: const HomeScreen(),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
        tall: true,
        recents: _FakeRecentPlaces.new,
      ));
  testWidgets('home with next trip', (t) => shot(
        t,
        'home_next_trip',
        Scaffold(
          body: const HomeScreen(),
          bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: (_) {}),
        ),
        prime: (c) async {
          bookings.pages = [[sample('SL-8K2M')]];
          c.read(authControllerProvider);
          await Future<void>.microtask(() {});
        },
        recents: _FakeRecentPlaces.new,
      ));
  testWidgets('home dark', (t) => shot(
        t,
        'home_dark',
        Scaffold(
          body: const HomeScreen(),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
        theme: AppTheme.dark(),
        tall: true,
      ));
  testWidgets('journey date time picker', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(loadFonts);
    final c = container();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: MaterialApp(theme: AppTheme.light(), home: const JourneyScreen())));
    await tester.pumpAndSettle();
    showJourneyDateTimeSheet(tester.element(find.byType(JourneyScreen)), title: 'Pickup date & time', minimum: DateTime.now(), initial: DateTime.now().add(const Duration(days: 1, hours: 1)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/journey_date_time_picker.png'));
  });
  testWidgets('journey', (t) => shot(t, 'journey', const JourneyScreen()));
  testWidgets('journey filled', (t) => shot(t, 'journey_filled', const JourneyScreen(), prime: (c) async {
        c.read(bookingFlowProvider.notifier).updateJourney((_) => quotableJourney.copyWith(
              dropoff: const PlaceSelection(address: 'Heathrow Airport Terminal 5', placeId: 'h', latitude: 51.47, longitude: -0.49),
              isReturn: true,
              returnDate: DateTime(2026, 10, 5),
              returnTime: const TimeOfDay(hour: 14, minute: 0),
            ));
      }));
  testWidgets('journey when', (t) => shot(t, 'journey_when', const JourneyScreen(), prime: (c) async {
        c.read(bookingFlowProvider.notifier).updateJourney((_) => quotableJourney.copyWith(
              dropoff: const PlaceSelection(address: 'Heathrow Airport Terminal 5', placeId: 'h', latitude: 51.47, longitude: -0.49),
              isReturn: true,
              returnDate: DateTime(2026, 10, 5),
              returnTime: const TimeOfDay(hour: 14, minute: 0),
            ));
      }, act: (t) => t.tap(find.text('Continue'))));
  testWidgets('vehicle', (t) => shot(t, 'vehicle', const VehicleScreen(), prime: primeQuote));
  testWidgets('details', (t) => shot(t, 'details', const DetailsScreen(), prime: primeQuote));
  testWidgets('sign in', (t) => shot(t, 'sign_in', const SignInScreen()));
  testWidgets('airport', (t) => shot(t, 'airport', const ServiceScreen(kind: ServiceKind.airport), tall: true));
  testWidgets('cruise', (t) => shot(t, 'cruise', const ServiceScreen(kind: ServiceKind.cruise), tall: true));
  testWidgets('prices', (t) => shot(t, 'prices', const PricesScreen(), tall: true));
  testWidgets('journey dark', (t) => shot(t, 'journey_dark', const JourneyScreen(), theme: AppTheme.dark(), prime: primeQuote));
  testWidgets('vehicle dark', (t) => shot(t, 'vehicle_dark', const VehicleScreen(), theme: AppTheme.dark(), prime: primeQuote));
  testWidgets('airport dark', (t) => shot(t, 'airport_dark', const ServiceScreen(kind: ServiceKind.airport), theme: AppTheme.dark()));
  testWidgets('prices dark', (t) => shot(t, 'prices_dark', const PricesScreen(), theme: AppTheme.dark()));
  testWidgets('confirmation', (t) => shot(t, 'confirmation', const ConfirmationScreen(), prime: (c) async {
        await primeQuote(c);
        bookings.nextBooking = sample('SL-8K2M', paid: false);
        await c.read(bookingFlowProvider.notifier).confirmBooking(customerName: 'Ada Lovelace', customerPhone: '07700900000', customerEmail: 'ada@example.com');
      }));
  testWidgets('trips', (t) => shot(t, 'trips', const TripsScreen(), prime: (c) async {
        bookings.pages = [[sample('SL-8K2M'), sample('SL-7QPA', days: 12, paid: false), sample('SL-2BXA', days: -20)]];
      }));
  testWidgets('address search', (t) => shot(t, 'address_search', const AddressSearchScreen(title: 'Pickup', initial: PlaceSelection.empty, allowCurrentLocation: true)));
  testWidgets('profile', (t) => shot(t, 'profile', const ProfileScreen(), prime: (c) async {
        c.read(authControllerProvider);
        await Future<void>.microtask(() {});
      }));
  testWidgets('profile dark', (t) => shot(t, 'profile_dark', const ProfileScreen(), theme: AppTheme.dark(), prime: (c) async {
        c.read(authControllerProvider);
        await Future<void>.microtask(() {});
      }));
  testWidgets('trips dark', (t) => shot(t, 'trips_dark', const TripsScreen(), theme: AppTheme.dark()));
  testWidgets('trip detail', (t) => shot(t, 'trip_detail', const TripDetailScreen(reference: 'SL-8K2M'), prime: (c) async {
        bookings.nextBooking = sample('SL-8K2M');
      }));
}

/// Recents as a customer who has booked twice would have them, without the
/// preferences plugin the real notifier reads — its platform channel never
/// answers inside a widget test.
class _FakeRecentPlaces extends RecentPlaces {
  @override
  Future<List<PlaceSelection>> build() async => const [
        PlaceSelection(address: '14 Bedford Place, Southampton', placeId: 'a', latitude: 50.9107, longitude: -1.4055),
        PlaceSelection(address: 'Heathrow Airport', placeId: 'b', latitude: 51.4700, longitude: -0.4543),
      ];
}
