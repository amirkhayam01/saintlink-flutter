# Booking flow redesign — app + backend

> Status: in progress, September 2026. Successor to `design-plan.md`, which
> covered the screen-level rebuild and is now largely implemented. This plan
> covers the *flow* rather than the screens: where booking starts, how fast a
> customer reaches a price, and how the map behaves.
>
> **Progress:** Phases 0–5 complete (20 Sep 2026). The native map is built
> and its Android wiring verified by a debug APK build, but **tiles are
> unconfirmed** — no device on the build machine. First thing to do is run
> it on a phone. Phases 6 and 7 remain; neither needs anything from anyone.
> **Decided:** no map on Home (map loads are free, but Home has nothing to
> show on one); location asked for on the pickup tap only, never at launch.

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

### B4 — Only a browser Places key is configured — **RESOLVED** (Phase 1)

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

### Phase 1 — Provision native map keys — **DONE** (20 Sep 2026)

- [x] Maps SDK for Android, Maps SDK for iOS and **Geocoding API** enabled
- [x] Android key created, restricted to package `uk.co.saintslink.app` +
      this machine's debug SHA-1; API-restricted to Maps SDK for Android
- [x] iOS key created, restricted to bundle `uk.co.saintslink.saintsLink`;
      API-restricted to Maps SDK for iOS
- [x] Both in ignored files: `android/local.properties`
      (`googleMapsAndroidKey`), `ios/Flutter/Secrets.xcconfig`
      (`GOOGLE_MAPS_IOS_KEY`). A copy that had been pasted into `env.dart`
      was removed before it could be committed; git history confirmed clean.
- [ ] **Talha's debug SHA-1** must be added to the Android key or the map is
      grey on his machine
- [ ] Set a billing budget alert before the first build ships
- [ ] Add "register release SHA-1 on the Android key" to the release
      checklist — `build.gradle.kts` still signs release with the debug key

### Phase 2 — Surface recents, then make them real

Cheapest visible win. The data layer already exists.

#### 2A — App — **DONE** (20 Sep 2026, `b118351`)

- [x] "Recent" section on Home directly under the search bar, from the
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

### Phase 3 — Current location — **DONE** (20 Sep 2026; backend `d1f070e`, app `d860897`, dot `07f964c`)

**Decided 20 Sep, after discussion:** permission is asked for on the pickup
tap only — not at launch, not on opening the booking form. A launch prompt
is the one most people refuse, and on iOS a refusal is permanent. The
route maps show the "you are here" dot whenever permission *already* exists
(a check, never a request), so a customer who has tapped once gets it from
then on.

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

### Phase 4 — Native map — **DONE** (20 Sep 2026, `55ea6b1`)

- [x] `google_journey_map.dart` rewritten on `google_maps_flutter`;
      `webview_flutter` removed — the map was its only use. The browser-key
      plumbing (manifest tag, Gradle chain, `MainActivity` MethodChannel) is
      gone with it.
- [x] Pins for every located end, lettered in travel order (A, 1…n, B),
      camera fitted to their bounds with the header's route card kept clear.
      Typed-never-picked addresses get no pin. Nothing located → a nudge to
      pick from the suggestions, not an empty map.
- [x] Header preview is lite-mode with every gesture off; the expanded sheet
      is interactive. Dark style JSON in dark mode.
- [x] Keys: Android via `local.properties` → manifest placeholder →
      `com.google.android.geo.API_KEY`; iOS via `Secrets.xcconfig` →
      `Info.plist` → `GMSServices.provideAPIKey` in `AppDelegate`.
      `Secrets.xcconfig.example` committed as the template. README updated.
- [x] **Verified by `flutter build apk --debug`:** the key lands in the
      merged manifest under the tag the SDK reads. **Not verified: tiles.**
      No Android device or emulator on the build machine.
- [x] Tests stub the platform-views channel and the map's method channel
      (`test/support/platform_views.dart`), so screens around the map still
      pump and screenshot. App **130/130**, screenshots 24/24.
- [x] Route line: option **(a)** shipped — no line. See B1 and below.

**First thing next session: run it on a phone.** Grey tiles with no error
means the key restriction does not match the build that is running.

The route-line decision from the original plan, still open:
  - *(a)* Ship markers and fitted bounds, no line. Cheapest, and honest —
    nothing on screen then implies a routing accuracy we do not have.
  - *(b)* New Google Routes integration in the backend, polyline returned with
    the quote. Best looking, new recurring cost, and worth pairing with a review
    of whether the 1.22 multiplier should keep pricing off-catalogue journeys.

  **Recommendation: (a) now, (b) as its own piece of work** with the pricing
  question attached, rather than smuggling a pricing change in behind a
  cosmetic one.

### Phase 5a — Consistency pass — **DONE** (20 Sep 2026, `82c24ed`)

Inserted before the Home restructure so Home is rebuilt from settled
primitives. Twenty-two screens side by side showed four header treatments,
two field styles, four heading widgets and three hand-built list rows —
drift, not taste: `widgets/` held the shared pieces and newer screens built
their own beside them.

Six rules, decided once:

| Rule | Decision | Done |
|---|---|---|
| Header | Photo hero for marketing (Home, service pages); **gold** for tabs (Trips, Account); **midnight** for every task screen pushed into (booking flow, Your trip, Confirmation, Sign-in, search) | [x] Booking flow and Your trip moved to midnight; also fixes the light header on a dark screen. Decorative map asset removed from the bundle. |
| Primary button | The theme's pill | [x] No change needed — the FAB's "black border" was a **test-rendering artifact**: `flutter_test` draws elevation as a solid outline. Harness now renders real shadows. |
| Fields | Captions above (`FieldLabel`), not floating labels | [x] Journey screen moved; the caption doubles as the control's semantics label |
| Section heading | `SectionTitle` for sections, `GroupLabel` for list groups | [x] `HomeSectionHeading`, Account's `_SectionHeading`, search sheet's `_Heading` deleted |
| Card | The theme's `Card` — radius 16, border, flat | [x] Account's `_CardContainer` deleted |
| List row | Shared `ListRow` + `ListRowDivider` | [x] Account, search sheet and Recent all use it |

App **129/129** (one obsolete asset test removed), screenshots 24/24.

### Phase 5 — Home becomes the booking entry point — **DONE** (20 Sep 2026, `d0b55da`)

**Decided: no map on Home.** Native map loads are free, but a map on Home
would show the customer's position and nothing else — inDrive's need, not
this product's. The value of this phase was the *ordering*. Hero stays.

Home top to bottom now: hero → **next trip** (moved up from mid-page; gone
when there is none) → `Where to?` + shortcut chips → **Recent** → a
**Plan a journey** button → services → trust strip → popular fares. The three
things a returning customer needs are above the fold; the marketing is still
there for anyone still deciding.

- [x] Next-trip banner moved to the top of the sheet
- [x] "Plan a journey" button — the one explicit door into the full form,
      replacing what the tab used to be
- [x] Fleet carousel moved off Home to Routes & prices, beside the prices
      it explains
- [x] **`Book` tab removed.** `/book` left the shell and is a root route
      pushed over it with a back arrow; every door in (search, chips, Go
      again, service tiles, fare cards, the button) pushes. Three tabs:
      Home / Trips / **Account** (renamed from Profile to match its header).
- [x] Tests updated for the new paths — you cannot reach a tab from inside
      the form any more, which is the point. `home with next trip` added to
      the screenshot harness. App **129/129**, screenshots 25/25.

**Not verified on a device**, same as Phase 4. Worth checking on a phone:
the back arrow from the form lands on whichever screen opened it.

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
Days 6–8      Phase 4 (native map)                  ✅ DONE │
              Phase 5a (consistency pass)         ✅ DONE │
Days 9–12     Phase 5 (Home as booking entry)       ✅ DONE
Days 13–14    Phase 6 (split journey form)          ← NEXT
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
- Map unavailable, with and without a network — *partly*: nothing-located
  and stubbed-platform cases are covered; a real network-loss render needs
  a device
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
4. ~~**Does dropping the `Book` tab need sign-off?**~~ Signed off and done
   20 Sep.
