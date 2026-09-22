import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/domain/customer.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/auth/auth_controller.dart';
import 'package:saints_link/src/features/places/recent_places.dart';

// The server's list leads, the device fills in behind, nothing repeats.

const home = PlaceSelection(
  address: '14 Bedford Place, Southampton',
  placeId: 'home',
  latitude: 50.91,
  longitude: -1.40,
);
const heathrow = PlaceSelection(
  address: 'Heathrow Airport',
  latitude: 51.47,
  longitude: -0.45,
);
const gatwick = PlaceSelection(
  address: 'Gatwick Airport',
  latitude: 51.15,
  longitude: -0.18,
);
const cruise = PlaceSelection(
  address: 'Southampton Cruise Terminals',
  latitude: 50.90,
  longitude: -1.41,
);

class _Device extends RecentPlaces {
  _Device(this.places);
  final List<PlaceSelection> places;

  @override
  Future<List<PlaceSelection>> build() async => places;
}

class _SignedInAuth extends AuthController {
  @override
  AuthState build() => const AuthState.signedIn(
    Customer(
      id: 1,
      name: 'Alex Morgan',
      firstName: 'Alex',
      phone: '+447700900123',
      maskedPhone: '+44 7700 900123',
      marketingConsent: false,
    ),
  );
}

Future<List<PlaceSelection>> goAgain({
  required List<PlaceSelection> synced,
  required List<PlaceSelection> device,
}) async {
  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(_SignedInAuth.new),
      customerPlacesProvider.overrideWith((ref) async => synced),
      recentPlacesProvider.overrideWith(() => _Device(device)),
    ],
  );
  addTearDown(container.dispose);

  // Both sources are async; let them settle before reading the merge.
  await container.read(customerPlacesProvider.future);
  await container.read(recentPlacesProvider.future);

  return container.read(goAgainPlacesProvider);
}

void main() {
  test('the server list leads and the device fills in behind it', () async {
    final places = await goAgain(
      synced: [heathrow, home],
      device: [cruise, gatwick],
    );

    expect(places, [heathrow, home, cruise, gatwick]);
  });

  test('a place the server already lists is not repeated from the device', () async {
    final places = await goAgain(
      synced: [heathrow, home],
      // Same house by place id; same airport by name, as a shortcut has no id.
      device: [
        home.copyWith(address: '14 Bedford Pl, Southampton SO15'),
        heathrow,
        gatwick,
      ],
    );

    expect(places, [heathrow, home, gatwick]);
  });

  test('a guest does not see another customer\'s device history', () async {
    final container = ProviderContainer(
      overrides: [
        customerPlacesProvider.overrideWith(
          (ref) async => const <PlaceSelection>[],
        ),
        recentPlacesProvider.overrideWith(() => _Device([cruise])),
      ],
    );
    addTearDown(container.dispose);

    final places = container.read(goAgainPlacesProvider);

    expect(places, isEmpty);
  });
}
