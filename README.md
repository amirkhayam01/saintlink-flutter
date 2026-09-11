# Saints Link customer app

Flutter app for customers: get a fixed price, book, pay in-app, and manage trips.
It is a second client on the same Laravel backend as the website — every price,
rule and policy comes from `/api/v1`, which runs the same services the site does.

## Run

```bash
cd mobile
flutter pub get
# Android emulator reaching a local `php artisan serve`:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
# A physical phone on the same Wi-Fi:
flutter run --dart-define=API_BASE_URL=http://<your-machine-ip>:8000/api/v1
```

Without `API_BASE_URL` the app points at `https://saintslink.co.uk/api/v1`.
When it is pointed anywhere else, the first screen shows which backend it is
talking to so a test booking never lands somewhere unexpected.

Toolchain: Flutter 3.47 / Dart 3.13 (stable). Android minSdk 23, iOS 15.

## Backend setup for local use

In the Laravel `.env`:

```
SMS_PROVIDER=log          # sign-in codes are written to storage/logs/laravel.log
PAYMENTS_ENABLED=true     # optional; needs STRIPE_SECRET_KEY + STRIPE_PUBLISHABLE_KEY
GOOGLE_PLACES_API_KEY=    # optional; without it the app still books from typed addresses
```

Then `php artisan migrate` (two new tables: `customer_otp_codes`,
`personal_access_tokens`; two new columns on `customers`) and
`php artisan serve --host=0.0.0.0`.

To sign in locally, request a code in the app and read it from the log:
`grep "sign-in code" storage/logs/laravel.log | tail -1`.

## Structure

```
lib/src/
  core/        env, ApiClient (Dio), ApiException, TokenStore, theme, formatting
  features/
    auth/      phone + OTP sign-in, AuthController (session restore)
    booking/   JourneyDraft, BookingFlowController, journey → vehicle → details → confirmed
    places/    address search proxied via the server (no Google key in the app)
    payment/   Stripe PaymentSheet wrapper
    trips/     my bookings, detail, pay, request cancellation
  profile/   your details (name, email, marketing consent); phone is identity, not editable
  router.dart  go_router; /trips and /profile require sign-in, booking does not
```

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

## Not yet built

- Push notifications (driver assigned / on the way). The customer guard and
  device-named tokens are in place; an FCM token column and a notification
  service are the remaining backend work.
