/// Editorial content for the service and price pages. "From" prices only; the charge always comes from a quote.
class Content {
  const Content._();

  static const airports = <Destination>[
    Destination(
      name: 'Heathrow',
      code: 'LHR',
      fromPrice: 125,
      address: 'London Heathrow Airport (LHR)',
      travelTime: 'about 1 hr 30',
    ),
    Destination(
      name: 'Gatwick',
      code: 'LGW',
      fromPrice: 140,
      address: 'London Gatwick Airport (LGW)',
      travelTime: 'about 1 hr 45',
    ),
    Destination(
      name: 'Southampton',
      code: 'SOU',
      fromPrice: 18.60,
      address: 'Southampton Airport (SOU)',
      travelTime: 'about 15 min',
    ),
    Destination(
      name: 'Bournemouth',
      code: 'BOH',
      fromPrice: 70,
      address: 'Bournemouth Airport (BOH)',
      travelTime: 'about 40 min',
    ),
    Destination(
      name: 'Stansted',
      code: 'STN',
      fromPrice: 240,
      address: 'London Stansted Airport (STN)',
      travelTime: 'about 2 hrs 20',
    ),
    Destination(
      name: 'Luton',
      code: 'LTN',
      fromPrice: 220,
      address: 'London Luton Airport (LTN)',
      travelTime: 'about 2 hrs 10',
    ),
  ];

  static const cruiseTerminals = <Destination>[
    Destination(
      name: 'Ocean Terminal',
      code: '',
      fromPrice: 18.60,
      address: 'Ocean Cruise Terminal, Southampton',
      travelTime: 'about 10 min',
    ),
    Destination(
      name: 'Mayflower Terminal',
      code: '',
      fromPrice: 18.60,
      address: 'Mayflower Cruise Terminal, Southampton',
      travelTime: 'about 10 min',
    ),
    Destination(
      name: 'City Cruise Terminal',
      code: '',
      fromPrice: 18.60,
      address: 'City Cruise Terminal, Southampton',
      travelTime: 'about 10 min',
    ),
    Destination(
      name: 'QEII Terminal',
      code: '',
      fromPrice: 18.60,
      address: 'Queen Elizabeth II Cruise Terminal, Southampton',
      travelTime: 'about 10 min',
    ),
    Destination(
      name: 'Horizon Terminal',
      code: '',
      fromPrice: 18.60,
      address: 'Horizon Cruise Terminal, Southampton',
      travelTime: 'about 10 min',
    ),
    Destination(
      name: 'Portsmouth Port',
      code: '',
      fromPrice: 45,
      address: 'Portsmouth International Port',
      travelTime: 'about 35 min',
    ),
  ];

  static const routeGroups = <RouteGroup>[
    RouteGroup(
      label: 'Airport',
      routes: [
        FixedRoute(from: 'Southampton', to: 'Heathrow Airport', fromPrice: 125),
        FixedRoute(from: 'Southampton', to: 'Gatwick Airport', fromPrice: 140),
        FixedRoute(from: 'Southampton', to: 'Luton Airport', fromPrice: 220),
        FixedRoute(from: 'Southampton', to: 'Stansted Airport', fromPrice: 240),
        FixedRoute(
          from: 'Southampton',
          to: 'Bournemouth Airport',
          fromPrice: 70,
        ),
        FixedRoute(
          from: 'Southampton',
          to: 'Southampton Airport',
          fromPrice: 18.60,
        ),
      ],
    ),
    RouteGroup(
      label: 'Cruise',
      routes: [
        FixedRoute(
          from: 'Heathrow Airport',
          to: 'Southampton Cruise Terminals',
          fromPrice: 125,
        ),
        FixedRoute(
          from: 'Gatwick Airport',
          to: 'Southampton Cruise Terminals',
          fromPrice: 140,
        ),
        FixedRoute(
          from: 'Central London',
          to: 'Ocean Cruise Terminal',
          fromPrice: 160,
        ),
        FixedRoute(
          from: 'Southampton Central',
          to: 'Mayflower Cruise Terminal',
          fromPrice: 18.60,
        ),
      ],
    ),
    RouteGroup(
      label: 'Local',
      routes: [
        FixedRoute(from: 'Southampton', to: 'Winchester', fromPrice: 35),
        FixedRoute(from: 'Southampton', to: 'Portsmouth', fromPrice: 40),
        FixedRoute(from: 'Southampton', to: 'Salisbury', fromPrice: 55),
        FixedRoute(from: 'Southampton', to: 'Bournemouth', fromPrice: 45),
        FixedRoute(from: 'Southampton', to: 'Central London', fromPrice: 160),
      ],
    ),
  ];
}

class Destination {
  const Destination({
    required this.name,
    required this.code,
    required this.fromPrice,
    required this.address,
    required this.travelTime,
  });

  final String name;
  final String code;
  final double fromPrice;

  /// What goes into the journey form when the customer taps "Get a quote".
  final String address;
  final String travelTime;
}

class FixedRoute {
  const FixedRoute({
    required this.from,
    required this.to,
    required this.fromPrice,
  });

  final String from;
  final String to;
  final double fromPrice;
}

class RouteGroup {
  const RouteGroup({required this.label, required this.routes});

  final String label;
  final List<FixedRoute> routes;
}
