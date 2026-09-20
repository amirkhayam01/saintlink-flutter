# Booking flow redesign — app + backend

> Status: in progress, September 2026. Successor to `design-plan.md`, which
> covered the screen-level rebuild and is now largely implemented. This plan
> covers the *flow* rather than the screens: where booking starts, how fast a
> customer reaches a price, and how the map behaves.
>
> **Progress:** Phases 0, 2 and 3 complete (20 Sep 2026). Phase 1 in
> progress — SDKs enabled, keys still to be created and restricted. Phase 4
> (native map) is next and is blocked on those keys.

Spans two repositories:

- **App** — `saintslink-flutter` (Flutter, Riverpod, go_router, freezed)
- **Backend** — `saintslink` (Laravel, `/api/v1`, shared with the website)

The trigger was a comparison against inDrive. Read `Non-goals` first — the useful
half of that comparison is small and specific, and the tempting half would do
real damage.

---

## Non-goals

inDrive is a **reverse-bidding marketplace**: the passenger proposes a fare and
drivers accept, decline, or counter. Their entire interface serves that model —
the `− Rs523 +` fare stepper, "Recommended fare", "Auto-accept offer", and the
"Find offers" button that opens a negotiation.

Saints Link sells the opposite product. `service_screen.dart` says it plainly:
*"Your quote is exact."* The quote engine issues a signed `quote_token` with an
`expires_at`, and `booking_flow_controller` refuses to book against an expired
one. Price certainty is the differentiator.

**Therefore, explicitly not doing:**

- Any fare stepper, price negotiation, or "offers" vocabulary
- On-demand hailing — every journey here is pre-booked for a pickup time
- A driver-bidding or driver-matching surface; there are no driver fields on the
  booking model, and dispatch is a back-office concern
- A wholesale visual reskin. The gold/midnight palette, Figtree, the theme
  tokens and `InnerScreenHeader` stay exactly as they are

Also keep what we already do better than inDrive: vehicle photos, and passenger
/ suitcase / hand-luggage capacity on every fare card. For an airport transfer,
*will my luggage fit* is the actual question being asked.

---

## Backend review — findings

Reviewed `routes/api.php`, the `Api\V1` controllers, `QuoteService`,
`JourneyQuoteService`, `GooglePlacesService` and the customer migrations.

The API is in good shape: versioned in the path, Sanctum on a named `customer`
guard, throttles chosen per-endpoint for a real reason (SMS cost, Google
billing), guest quoting and guest booking supported, and the Places key proxied
server-side so it never ships in the binary. The doc comments explain intent
rather than mechanics. Extending it is the right move; it does not need
restructuring.

Five findings matter for this plan.

### B1 — There is no routing API. Distances are estimated, not routed

`JourneyQuoteService` measures each leg with **haversine great-circle distance
multiplied by a constant `ROAD_DISTANCE_MULTIPLIER = 1.22`**
(`JourneyQuoteService.php:426`, `:1088`). There is no call to Google Directions,
Routes, or Distance Matrix anywhere in `app/`.

This corrects an earlier assumption in discussion: **the backend cannot "just
return the route polyline with the quote," because it never computes a route.**
Drawing a real route line means a new Google Routes API integration, with new
per-request cost, not a field added to an existing response.

Note this is mostly a *display* concern, not a pricing one. Catalogue routes
(Southampton → Heathrow and friends) are priced from a fixed-rate table, so the
1.22 estimate only drives off-catalogue journeys. Whether that estimate is good
enough for pricing is a separate business question and out of scope here.

### B2 — No reverse geocoding endpoint — **RESOLVED** (Phase 3)

`PlacesController` exposes `autocomplete` and `details` only. "Use my current
location" produces a lat/lng, and a lat/lng needs turning into an address a
customer recognises and a driver can drive to. That endpoint does not exist yet.

### B3 — Saved places do not exist server-side — **RESOLVED** (Phase 2B)

`recent_places.dart` keeps the last 5 located places in `SharedPreferences`, on
the device. Nothing in `app/` or `database/migrations/` has any concept of a
saved or favourite place. Consequences: recents are lost on reinstall, never
reach a second device, and the "Favourite locations" row on the account screen
has nothing to be wired to.

### B4 — Only a browser Places key is configured

`config/services.php` has `google.places_key` and nothing else. The map WebView
obtains a *referrer-restricted browser key* over a `MethodChannel`. Native Maps
SDKs cannot use that kind of key — they need a Maps SDK for Android key
(restricted by package name + SHA-1) and a Maps SDK for iOS key (restricted by
bundle ID). **This is the long-lead item in the whole plan.**

**Update, 20 Sep:** both SDKs enabled in the console. Keys not yet created.
The restriction values, found in the project — and easy to get wrong because
this project has three different-looking identifiers:

| Key | Restriction | Value |
|---|---|---|
| Android | Package name | `uk.co.saintslink.app` — the **applicationId**, *not* the Gradle `namespace` `uk.co.saintslink.saints_link`. The wrong one gives grey tiles with no error. |
| Android | SHA-1 (debug, this machine) | `83:C0:9D:A0:C1:8D:D5:4E:2F:36:EC:12:BC:51:AF:B9:09:58:AD:8B` — each developer's debug keystore differs; add Talha's too. |
| iOS | Bundle ID | `uk.co.saintslink.saintsLink` |

Neither existing key can be reused. A Google key has exactly one
application-restriction type — HTTP referrer, IP, Android app, iOS app — and
they are mutually exclusive. `VITE_GOOGLE_MAPS_API_KEY` is referrer-restricted
for the website; `GOOGLE_PLACES_API_KEY` is the server key the proxy exists to
protect. Two new keys, restricted by API to the two Maps SDKs only.

**Release-signing hazard:** `android/app/build.gradle.kts:54` still signs
release builds with the debug keystore (Flutter's `TODO` is intact). The day a
real release keystore is created for the Play Store, its SHA-1 must be added
to the Android key first or **the map goes blank in production**. Put it on
the release checklist now.

Delivery: mirror the existing `mapsBrowserKey` chain — `android/local.properties`
(already gitignored) → env var → sibling `.env` — as `googleMapsAndroidKey`,
injected into the standard `com.google.android.geo.API_KEY` manifest tag. The
Android SDK reads that itself; no MethodChannel needed. iOS:
`GMSServices.provideAPIKey()` in `AppDelegate.swift`.

### B5 — Bug: `PATCH /api/v1/me` can 500 on a cleared last name — **FIXED**

`customers.last_name` is declared `$table->string('last_name')` — **NOT NULL**
(`2026_04_04_000050_create_customers_table.php:15`), and no later migration
relaxes it. But `AuthController::updateMe` validates it as
`['sometimes', 'nullable', 'string', 'max:255']`, and the app sends `null`
whenever the field is empty:

```dart
// profile_controller.dart
lastName: lastName.trim().isEmpty ? null : lastName.trim(),
```

A customer who clears their last name and saves hits a NOT NULL violation on
MySQL in strict mode. Not caused by this redesign — worth fixing first because
Phase 0 already touches that screen.

**Fixed in Phase 0** (`saintslink@dc6d417`). Reproduced first: the new test
`a customer can clear their last name` failed with
`SQLSTATE[23000] ... NOT NULL constraint failed: customers.last_name` before
the migration and passes after it. Migration
`2026_09_20_000100_make_customer_last_name_nullable` relaxes the column and
normalises existing empty strings to null.

---

## Why the map loads, and theirs does not

The single clearest UX gap, and it is architectural rather than cosmetic.

`google_journey_map.dart` is **not a map**. It is a `WebViewController` running
the Google Maps *JavaScript* SDK inside an HTML string. Every appearance pays:

1. Fetch the browser key over a `MethodChannel`
2. Instantiate a WebView
3. `loadHtmlString`
4. The page downloads the Maps JS SDK **over the network**
5. Directions call
6. Render, then `postMessage('ready')`

Steps 4–5 are network round-trips on every single appearance. That is why the
file carries a **25-second timeout** (`:116`), a spinner, and a "Retry map"
button — all three exist because this genuinely hangs and fails.

inDrive uses the native Maps SDK: compiled into the binary, tiles cached on
disk, drawn as a platform view on the first frame. Nothing to download, nothing
to fail, no spinner.

`webview_flutter` is used in exactly one file, so the dependency can be dropped
entirely with the swap.

---

## Phases

Ordered by dependency, not by value. Phase 1 is an ops task with a lead time —
**start it on day one regardless of where implementation begins.**

### Phase 0 — Clear the decks — **DONE** (20 Sep 2026)

Prerequisite for everything; all later phases touch these files.

- [x] Merge the `amir` branch (review fixes on top of `talha`: dark-mode icon
      contrast, status-bar overlay style, the silent marketing-save failure,
      restored SDK constraints, 1.55 MB → 221 KB of images).
      Fast-forwarded `master` to `226ee3a`.
- [x] Fix **B5**: `customers.last_name` is now nullable, existing empty
      strings normalised to null, with a regression test that was confirmed
      failing beforehand. `saintslink@dc6d417`.
- [x] Confirm the suites are green on the merge result: `flutter analyze`
      clean, **120/120** app tests, **331/331** backend tests (2,401
      assertions).

### Phase 1 — Provision native map keys — **IN PROGRESS** (ops)

Blocks Phase 4 entirely. No code. Values and hazards are under **B4** above.

- [x] Google Cloud console: enable **Maps SDK for Android** and **Maps SDK for iOS**
- [ ] Create the Android key, restricted to package `uk.co.saintslink.app` +
      debug SHA-1(s); API-restricted to Maps SDK for Android
- [ ] Create the iOS key, restricted to bundle `uk.co.saintslink.saintsLink`;
      API-restricted to Maps SDK for iOS
- [ ] Put both in `android/local.properties` / iOS config — not in chat, not
      in the backend `.env`
- [ ] Set a billing budget alert before the first build ships
- [ ] Add "register release SHA-1 on the Android key" to the release checklist

### Phase 2 — Surface recents, then make them real

Cheapest visible win. The data layer already exists.

#### 2A — App — **DONE** (20 Sep 2026, `b118351`)

- [x] "Go again" section on Home directly under the search bar, from the
      existing `recentPlacesProvider`. Hidden until there is real history —
      the chip row already offers every shortcut, so a fallback list would be
      a copy of the row above it.
- [x] The shortcut chips are now the shortcut list itself rather than a
      second hand-written copy of it, so the server's canonical names are the
      only spelling in the app. IATA codes kept on the labels.
      **Correction (found during 2B):** this was first recorded as a pricing
      fix — "the engine matched by text instead of measuring". It is not.
      `GooglePlacesService::secureJourney` discards every client coordinate
      the server did not verify against Google itself, so the chips'
      positions never reach the engine; a catalogue name like "Heathrow
      Airport" is placed from the server's own list either way. The real gain
      was one source of truth for the names. Comments and the test were
      corrected in `adc0020`.
- [x] `home with recents` added to the screenshot harness via a fake
      notifier; the real one reads SharedPreferences, whose channel never
      answers in a widget test. `booking_home_reset_test` now asserts
      `dropoff.isLocated`.

#### 2B — Backend and sync — **DONE** (20 Sep 2026; backend `cb63551`, app `adc0020`)

**Decided: implicit frequency list.** No labels, no naming UI. A booking is
the signal.

- [x] `customer_places` table, `CustomerPlace` model, `CustomerPlaceService`.
      Keyed by place id, or by coordinates to four decimals for a shortcut
      that has none — so two bookings to the same shortcut land on one row.
- [x] Recording hooked into `Api\V1\BookingController::store` after the
      transaction, never allowed to fail the booking. Guests record nothing.
- [x] **Found while there:** an app shortcut arrives at the server with no
      coordinates at all (see the 2A correction above), so it could never
      have been remembered. `JourneyQuoteService` gained a public
      `locate(address)` exposing the same profile-then-service-location
      resolution it already uses to price, and the row gets the position the
      engine priced it at.
- [x] `GET /api/v1/places/recent`, `DELETE /api/v1/places/recent/{id}`
      (scoped to the caller). Documented in `docs/mobile-api.md`.
- [x] App: `customerPlacesProvider` fetches when signed in and not in a
      preview session; `goAgainPlacesProvider` merges it ahead of the device
      list, deduplicated by place id or name. A confirmed booking invalidates
      the synced list. Home and the address search field both read the merge.
- [x] Five backend tests (both ends remembered, repeat bookings counted not
      duplicated, unplaceable end skipped, guest records nothing, list order
      and scoped forget). Three app tests for the merge rule. Backend
      **336/336**, app **123/123**, screenshots 24/24.

Device recents stay as the offline fallback and as the guest experience.
**Not yet wired:** the "Favourite locations" row on the account screen is
still *Coming soon*. It now has a real source — a most-used list with a
forget action — and is a small follow-up rather than part of this phase.

### Phase 3 — Current location — **DONE** (20 Sep 2026; backend `d1f070e`, app `d860897`)

- [x] **Backend, resolving B2:** `GET /api/v1/places/reverse?lat=&lng=` in
      the throttled places group, same shape as `places/details`. Google
      Geocoding API, rooftop result types first, cached on the position to
      four decimals so a double tap is billed once. 422 with a message
      outside the UK or where there is nothing to name; 503 the app can
      retry on a Google failure. Six tests. Documented in `mobile-api.md`.
- [x] **App:** `geolocator` behind a one-method `LocationSource`, so the
      flow is testable without a device and the app cannot grow a location
      watcher by accident. `ACCESS_COARSE/FINE_LOCATION` in the manifest,
      `NSLocationWhenInUseUsageDescription` in `Info.plist`.
- [x] "Use my current location" row at the top of the **pickup** search
      only, threaded as `allowCurrentLocation` from `_RouteStop`. Prompt on
      that tap, never at launch; foreground only.
- [x] Every failure says something actionable and leaves the search usable:
      services off, refused once, refused for good (with an **Open settings**
      action — the app can no longer ask), no fix within 12 s, or the
      server's refusal in its own words. Five widget tests. App **128/128**,
      screenshots 24/24, backend **342/342**.

**Needs from ops:** the server key (`GOOGLE_PLACES_API_KEY`) must have the
**Geocoding API** enabled alongside Places, or `/places/reverse` returns 503.

**Correction to the original text above:** a GPS fix on its own would *not*
have priced precisely — `secureJourney` discards unverified client
coordinates. It is the reverse geocode's verified `place_id` that makes the
engine trust the position, which is why the endpoint returns one.

### Phase 4 — Native map (app 2–3 days, blocked on Phase 1)

Replace `google_journey_map.dart` with `google_maps_flutter`; delete
`webview_flutter`.

- Markers for pickup, stops and dropoff; camera fitted to their bounds
- A dark map style JSON, so the map stops being a light grey `#EAF0EF` panel in
  dark mode
- **The route line is a decision, not a given** (see B1). Options:
  - *(a)* Ship markers and fitted bounds, no line. Cheapest, and honest —
    nothing on screen then implies a routing accuracy we do not have.
  - *(b)* New Google Routes integration in the backend, polyline returned with
    the quote. Best looking, new recurring cost, and worth pairing with a review
    of whether the 1.22 multiplier should keep pricing off-catalogue journeys.

  **Recommendation: (a) now, (b) as its own piece of work** with the pricing
  question attached, rather than smuggling a pricing change in behind a
  cosmetic one.

### Phase 5 — Home becomes the booking entry point (app 3–4 days)

The largest change and the main prize.

Today Home is a marketing page — greeting, hero, search field, services grid,
trust strip, popular fares, fleet carousel — and booking lives in a *separate
tab*. Good for a first-time visitor being convinced. Pure friction for the
third-time customer going to Heathrow again.

- Hero or map at top, `Where to?` and recents/saved immediately beneath
- Services, trust strip, fleet demoted below the fold or moved into Services
- **The `Book` tab becomes redundant** — bottom nav goes 4 items to 3
  (Home / Trips / Profile), which needs a `router.dart` change and a redirect
  for anything still pointing at `/book`
- Keep the trust messaging on the page. It is the differentiator; it just does
  not need to be on the critical path every single time

### Phase 6 — Shorten time-to-first-price (app 2 days)

`journey_screen` asks for pickup, destination, stops, date/time, return toggle,
return date, passengers and suitcases — seven inputs before a single price
appears. inDrive asks two, then shows prices.

Split it: **route first**, then *when and who* as a second step. Surface an
indicative price as early as the engine can give one. This is the metric worth
optimising, and it is independent of Phase 5 — they can ship in either order.

### Phase 7 — Vehicle list polish (app 1 day)

`vehicle_screen` renders every fare card at full height; roughly three and a
half fit on screen. Collapse unselected cards to a one-line summary and expand
the selected one. Same information, far less scrolling, and no change to
pricing, capacity display or the sticky `Continue · £155.00` bar.

---

## Sequencing

```
Day 1     ├── Phase 1 (ops: request map keys) ────── 🔶 SDKs on, keys pending
Day 1     └── Phase 0 (merge amir, fix B5)          ✅ DONE │
Days 2–3      Phase 2A (recents on Home)            ✅ DONE │
              Phase 2B (customer_places + sync)     ✅ DONE │
Days 4–5      Phase 3 (current location)            ✅ DONE │
Days 6–8      Phase 4 (native map) ◄─── ← NEXT, blocked on keys ┘
Days 9–12     Phase 5 (Home as booking entry)
Days 13–14    Phase 6 (split journey form)
Day 15        Phase 7 (vehicle list)
```

Phases 2, 3, 6 and 7 are independent of the key provisioning and can absorb any
delay in Phase 1.

**Backend: done** for every phase except the optional Routes API integration
in Phase 4(b).
Larger only if the Routes API integration in Phase 4(b) is approved.

---

## Testing

The rule from `design-plan.md` still holds: **controllers, repositories and
routes change only where a phase explicitly says so.** The existing 120 tests
assert state, not pixels, and should stay green throughout.

The screenshot harness is the tool for the visual work:

```bash
SCREENSHOTS=1 flutter test test/screenshots --update-goldens
```

`profile dark` and `trips dark` were added to it during the review — a dark
render is what exposed six icons that were invisible against the dark card
colour. **Every new or restructured screen in this plan gets a dark variant in
that harness.** It is the cheapest regression net we have for exactly the class
of bug that keeps appearing.

New coverage worth writing:

- ~~Location permission denied, and permission permanently denied~~ done
- ~~Reverse geocode failure — the pickup field must stay usable~~ done
- Map unavailable, with and without a network
- ~~Guest vs signed-in recents (device-only vs synced)~~ done

---

## Open questions

1. **Phase 4(b): approve a Google Routes integration?** Real recurring cost.
   Decide alongside whether the 1.22 multiplier should keep pricing
   off-catalogue journeys.
2. ~~**Saved places — labelled or implicit?**~~ **Decided: implicit.** A
   frequency list, no labels. Table shape in Phase 2B reflects this.
3. ~~**Who owns the Google Cloud project**~~ SDKs enabled 20 Sep; keys still
   to be created against the values under B4.
4. **Does dropping the `Book` tab need sign-off?** It is the most visible change
   in the plan to anyone already using the app.
