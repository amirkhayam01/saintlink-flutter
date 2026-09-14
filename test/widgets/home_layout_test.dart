import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/domain/vehicle_category.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/home/home_screen.dart';
import 'package:saints_link/src/widgets/tiles.dart';

import '../support/fakes.dart';

class RefreshRepository extends FakeBookingRepository {
  int requests = 0;
  Completer<List<VehicleCategory>>? refresh;

  @override
  Future<List<VehicleCategory>> vehicleCategories() async {
    requests++;
    if (requests > 1 && refresh != null) return refresh!.future;
    return vehicles;
  }
}

void main() {
  for (final width in [320.0, 390.0, 768.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('home fits width $width with text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              bookingRepositoryProvider.overrideWithValue(
                FakeBookingRepository()
                  ..vehicles = fixtureVehicles()
                  ..nextBooking = bookingWith(),
              ),
              authRepositoryProvider.overrideWithValue(
                FakeAuthRepository()..hasSession = true,
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const HomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (width == 390 && scale == 1) {
          expect(
            tester.getSize(find.byType(ServiceTile).first).height,
            lessThan(150),
          );
        }
        for (var i = 0; i < 8; i++) {
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -350),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('pull refresh waits for fleet and retains the journey', (
    tester,
  ) async {
    final repository = RefreshRepository()..vehicles = fixtureVehicles();
    final container = ProviderContainer(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(repository),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    container
        .read(bookingFlowProvider.notifier)
        .updateJourney((_) => quotableJourney);
    repository.refresh = Completer<List<VehicleCategory>>();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 350));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(repository.requests, 2);
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    expect(find.text('Our services'), findsOneWidget);
    expect(container.read(bookingFlowProvider).journey, quotableJourney);
    repository.refresh!.complete(fixtureVehicles());
    await tester.pumpAndSettle();
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
