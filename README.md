# Saints Link customer app

Flutter app for customers: get a fixed price, book, pay in-app, and manage trips.
It is a second client on the same Laravel backend as the website — every price,
rule and policy comes from `/api/v1`, which runs the same services the site does.

## Run

```bash
flutter pub get
# Android emulator reaching a local `php artisan serve`:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
# A physical phone on the same Wi-Fi:
flutter run --dart-define=API_BASE_URL=http://<your-machine-ip>:8000/api/v1
```

Without `API_BASE_URL` the app points at `https://saintslink.co.uk/api/v1`.
When it is pointed anywhere else, the first screen shows which backend it is
talking to so a test booking never lands somewhere unexpected.

Toolchain: Flutter 3.47 / Dart 3.13 (stable). Android minSdk 24, iOS 15.

## Booking route maps

Vehicle and Details show the journey on a native Google map — every end of it
that has a verified position, pinned and framed. The compact preview in the
header reserves room for the From/To overlay and is not pannable; expanding
opens an interactive map in a sheet. Dark mode gets a dark map.

It is the native Maps SDK, not a WebView: the SDK is compiled in and caches
its tiles, so the map draws on the first frame with no spinner. A route line
is a visual guide only; the backend remains authoritative for the distance,
duration and price shown to the customer.

**Keys.** Native SDK keys ship inside the binary, so each is restricted in
the Google console to the app's own identity and to one API, and a copy lifted
from the binary can do nothing else with it. They are never committed:

| Platform | File (ignored by git) | Line |
|---|---|---|
| Android | `android/local.properties` | `googleMapsAndroidKey=AIza…` |
| iOS | `ios/Flutter/Secrets.xcconfig` (copy `Secrets.xcconfig.example`) | `GOOGLE_MAPS_IOS_KEY=AIza…` |

CI can supply `GOOGLE_MAPS_ANDROID_KEY` in the environment instead. The
Android key must be restricted to package `uk.co.saintslink.app` — the
`applicationId`, not the Gradle namespace — plus each developer's debug SHA-1
and, once one exists, the release keystore's. Grey tiles with no error means
the restriction does not match the build that is running. Use a full rebuild
after changing a key or native plugin configuration.

## Backend setup for local use

In the Laravel `.env`:

```
SMS_PROVIDER=log          # sign-in codes are written to storage/logs/laravel.log
OTP_STATIC_CODE=123456    # optional: every sign-in accepts this code (testing only)
PAYMENTS_ENABLED=true     # optional; with the stripe driver needs STRIPE_SECRET_KEY + STRIPE_PUBLISHABLE_KEY
PAYMENTS_DRIVER=fake      # optional: in-app payments succeed without Stripe, on a labelled test sheet
GOOGLE_PLACES_API_KEY=    # optional; without it the app still books from typed addresses
```

## Test mode before SMS and Stripe are live

Both switches are backend `.env` settings, so the same app build works for
testing today and for real customers later:

- `OTP_STATIC_CODE=123456` — the server issues that code to every sign-in
  instead of a random one. It is still hashed, still expires and still counts
  attempts. **Remove it the moment a real SMS provider is configured**: with it
  set, anyone who knows a customer's number can sign in as them.
- `PAYMENTS_DRIVER=fake` (with `PAYMENTS_ENABLED=true`) — `payment-intent`
  answers with `provider: fake`, the app shows a bottom sheet titled "Test
  payment" with a warning banner instead of Stripe's sheet, and tapping Pay
  calls `payment-intent/confirm-test`, which marks the booking paid through
  the same code the Stripe webhook uses. With the stripe driver that endpoint
  returns 422, so it cannot be abused once payments are real.

Then `php artisan migrate` (two new tables: `customer_otp_codes`,
`personal_access_tokens`; two new columns on `customers`) and
`php artisan serve --host=0.0.0.0`.

To sign in locally, request a code in the app and read it from the log:
`grep "sign-in code" storage/logs/laravel.log | tail -1`.

## Structure

```
lib/src/
  core/        env, ApiClient (Dio), ApiException, TokenStore, ErrorReporter, theme (light + dark), formatting, content (static page copy)
  domain/      freezed API models; every server date parsed to local time
  features/
    home/      launcher: photo hero, service tiles, popular fares, fleet
    auth/      phone + OTP sign-in, AuthController (session restore)
    booking/   JourneyDraft, BookingFlowController, journey → vehicle → details → confirmed
    places/    address search proxied via the server (no Google key in the app)
    payment/   Stripe PaymentSheet wrapper
    trips/     my bookings, detail, pay, request cancellation
    profile/   your details, support contacts, appearance, sign out
    services/  airport and cruise landing pages, routes & prices (static content)
    splash/    launch overlay, above the router
  widgets/     design kit: hero_banner + overlap sheet, tiles (service, field, contact, badges, callout, segmented tabs), ticket_card, route_timeline, skeleton
  router.dart  go_router with a three-tab shell; /trips and /profile require sign-in, booking does not
```

Screens are rendered to `test/screenshots/out/` with
`SCREENSHOTS=1 flutter test test/screenshots --update-goldens` so a design
change can be reviewed without a device. `docs/design-plan.md` records the
redesign and what was taken from the earlier prototype.

## The one invariant

`JourneyDraft` is the only thing that builds a request payload. The server
fingerprints the journey fields when it prices a quote and refuses a booking
whose fields differ, so the quote request and the booking request must be
derived from the same object. `test/journey_draft_test.dart` pins this.

## Stripe

The publishable key is served by the API with each PaymentIntent, so moving
between test and live mode is a backend `.env` change, not an app release.
Apple Pay needs the merchant id `merchant.uk.co.saintslink` registered in the
Apple Developer account and the Xcode capability enabled; Google Pay needs the
`com.google.android.gms.wallet.api.enabled` meta-data added to the manifest
once the Google Pay business profile is approved.

## Error reporting

`ErrorReporter` is a seam, not a service. `ConsoleErrorReporter` is the
default; to ship crash reporting, construct the real one in `main.dart`, call
`installGlobalHandlers()` on it and override `errorReporterProvider`. 5xx and
network failures are reported from `ApiClient`; 4xx never are — those are the
customer's to fix.

## Not yet built

- Push notifications (driver assigned / on the way). The customer guard and
  device-named tokens are in place; an FCM token column and a notification
  service are the remaining backend work.
