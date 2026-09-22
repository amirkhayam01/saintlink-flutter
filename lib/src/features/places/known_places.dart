import '../../domain/place.dart';

/// Places the app names itself — on the service pages, the fare cards and
/// the shortcut chips — with positions, so a preset can be pinned on the map
/// and routed like a picked address. The server places these by name when
/// pricing; the coordinates here are for the map.
class KnownPlaces {
  KnownPlaces._();

  static const all = <PlaceSelection>[
    PlaceSelection(address: 'Heathrow Airport', latitude: 51.4700, longitude: -0.4543),
    PlaceSelection(address: 'Gatwick Airport', latitude: 51.1537, longitude: -0.1821),
    PlaceSelection(address: 'London Stansted Airport', latitude: 51.8850, longitude: 0.2350),
    PlaceSelection(address: 'London Luton Airport', latitude: 51.8747, longitude: -0.3683),
    PlaceSelection(address: 'Bournemouth Airport', latitude: 50.7800, longitude: -1.8425),
    PlaceSelection(address: 'Southampton Airport', latitude: 50.9503, longitude: -1.3568),
    PlaceSelection(address: 'Southampton Cruise Terminals', latitude: 50.8994, longitude: -1.4114),
    PlaceSelection(address: 'Ocean Cruise Terminal, Southampton', latitude: 50.8955, longitude: -1.4022),
    PlaceSelection(address: 'Mayflower Cruise Terminal, Southampton', latitude: 50.9010, longitude: -1.4160),
    PlaceSelection(address: 'City Cruise Terminal, Southampton', latitude: 50.8990, longitude: -1.4090),
    PlaceSelection(address: 'Queen Elizabeth II Cruise Terminal, Southampton', latitude: 50.8965, longitude: -1.4035),
    PlaceSelection(address: 'Horizon Cruise Terminal, Southampton', latitude: 50.9022, longitude: -1.4170),
    PlaceSelection(address: 'Portsmouth International Port', latitude: 50.8115, longitude: -1.0898),
    PlaceSelection(address: 'Southampton Central Station', latitude: 50.9075, longitude: -1.4140),
    PlaceSelection(address: 'Southampton', latitude: 50.9097, longitude: -1.4044),
    PlaceSelection(address: 'Central London', latitude: 51.5074, longitude: -0.1278),
  ];

  /// Other spellings the app's own copy uses for the same places.
  static const _aliases = <String, String>{
    'london heathrow airport (lhr)': 'Heathrow Airport',
    'london gatwick airport (lgw)': 'Gatwick Airport',
    'london stansted airport (stn)': 'London Stansted Airport',
    'stansted airport': 'London Stansted Airport',
    'london luton airport (ltn)': 'London Luton Airport',
    'luton airport': 'London Luton Airport',
    'bournemouth airport (boh)': 'Bournemouth Airport',
    'southampton airport (sou)': 'Southampton Airport',
    'southampton, uk': 'Southampton',
    'southampton central': 'Southampton Central Station',
    'ocean cruise terminal': 'Ocean Cruise Terminal, Southampton',
    'mayflower cruise terminal': 'Mayflower Cruise Terminal, Southampton',
    'city cruise terminal': 'City Cruise Terminal, Southampton',
    'qeii cruise terminal': 'Queen Elizabeth II Cruise Terminal, Southampton',
    'horizon cruise terminal': 'Horizon Cruise Terminal, Southampton',
  };

  /// The located place for a name the app uses, or the name alone when it
  /// is not one the app knows. Never null: a preset always lands somewhere.
  static PlaceSelection resolve(String address) {
    final key = address.trim().toLowerCase();
    final canonical = _aliases[key] ?? address.trim();
    for (final place in all) {
      if (place.address.toLowerCase() == canonical.toLowerCase()) return place;
    }
    return PlaceSelection(address: address.trim());
  }
}
