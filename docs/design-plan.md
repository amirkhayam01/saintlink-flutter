# Screen redesign plan — Saints Link customer app

> Status: Phases 0–4 implemented (September 2026). Kept as the record of what
> was taken from the prototype and why. Not done: the driver card on trip
> detail (no driver fields on the booking model yet) and live trip tracking.

Goal: keep the brand (gold `#FACC15` / midnight `#020617` / zinc neutrals, Figtree,
light + dark) and the architecture (Riverpod, go_router, freezed), but rebuild the
screen layouts using the visual ideas prototyped in `hampshirecab_App`.

Rule for every screen: **replace only `build()` bodies and widgets. Controllers,
repositories, routes and tests stay as they are.** The 62 tests test state, not
pixels, so they should keep passing throughout.

---

## Phase 0 — Settle the staged work (½ day)

`git status` shows uncommitted staged changes: a new `home_screen.dart` (1,237 lines),
`app_shell.dart` (4-tab nav), `theme_controller.dart`, router edits and test updates.
Its doc comments already describe: drawer, greeting header, upcoming-trip banner,
search launcher with hub chips, services grid, popular fares, fleet showcase, trust
strip — most of the hampshire home ideas.

1. Run `flutter test` and the screenshot test, look at the new home.
2. Decide: keep it as the base for Phase 2 (likely), or discard. Commit either way.
3. Split `home_screen.dart` into `features/home/widgets/*.dart` — 1,200 lines in one
   file is the wrong shape for what comes next.

---

## Phase 1 — Shared design kit (1 day)

Build these once in `lib/src/widgets/`, then every screen uses them. Most exist in
hampshire as one-off code; here they become reusable and theme-aware.

| Widget | From hampshire | Purpose |
|---|---|---|
| `HeroBanner` | `hero_banner_card.dart`, `home_screen.dart` hero | Full-bleed photo, dark gradient overlay, title + subtitle, optional back button. Used by Home, Airport, Cruise, Contact, Routes & Prices. |
| `OverlapSheet` | `Transform.translate(-18)` + top-radius container | White/card sheet with 24px top radius that overlaps the hero above it. |
| `ServiceTile` | `_buildServiceCard` | Icon in a soft circle + label, for 2×2 grids. Gold-tinted circle on light, midnight on dark. |
| `FieldTile` | `_buildLocationTile` | Label-over-value tappable row with leading icon and trailing chevron (Pickup / Destination / Date / Time / Passengers). Replaces the plain placeholders in the current journey form. |
| `CalloutCard` | route_fare "Fixed fare" callout | Midnight (light) / gold (dark) card with big number and a short promise line. |
| `InfoRow` | route_fare `_buildDetailRow` | Icon + label + value; already partly covered by `DetailRow` in `common.dart` — merge. |
| `BadgeRow` | `trust_badge_row.dart` | Three inline trust badges; the new home already has a `_TrustStrip` — extract it. |
| `SegmentedTabs` | my_bookings segmented "Upcoming / Past" | Pill-style segmented control to replace the plain `TabBar` in Trips. |
| `ContactTile` | contact_support `_buildContactCard` | Icon tile, title, subtitle, tap-to-call/mail/copy. |

Keep `TicketCard`, `RouteTimeline`, `StatusChip`, `StepIndicator`, `Skeleton` — those
are already good and hampshire has nothing better.

Also add to `theme.dart`: a `heroOverlay` gradient token and a `tint` colour
(gold at ~12% on light, gold at ~18% on dark) for icon circles and selected states.

---

## Phase 2 — Screen by screen

Effort estimates assume Phase 1 exists.

### 2.1 Home (`features/home/home_screen.dart`) — 1 day
Current: hero + big booking form + trust icons + fleet carousel. The form dominates
and the page has no "where do I go" structure.

Take from hampshire: **hero → overlapping sheet → 2×2 service grid → trust row**.

- Hero: keep the existing photo + "Welcome back, {name}" greeting (better than
  hampshire's "Hello!").
- Under the hero, in an `OverlapSheet`:
  - `ServiceTile` 2×2: Airport transfers · Cruise transfers · Private hire · Routes & prices.
    Airport/Cruise/Private-hire push `/book` with a preset `JourneyDraft`
    (`updateJourney` with a pickup/destination hint); Routes & prices opens the new
    screen in 2.9.
  - "Upcoming trip" banner if signed in and a booking exists (already in staged code).
  - Trust `BadgeRow`.
  - Fleet carousel (already exists) moves below the grid.
- Drop the full booking form from Home. Home becomes a launcher; the form lives on
  `/book`. A single "Where to?" `FieldTile` on Home that jumps to `/book` is enough.
- App bar: logo left, theme toggle + avatar right (staged code has this). Do **not**
  add hampshire's drawer — the 4-tab shell already covers navigation.

### 2.2 Journey form (`features/booking/journey_screen.dart`) — 1 day
Current: bare outlined boxes with placeholder text; return toggle; passengers dropdown.

Take from hampshire `booking_form_card.dart`:
- Every field becomes a `FieldTile` with a small uppercase label ("PICKUP LOCATION")
  above the value, leading icon, trailing chevron. Empty state reads "Select pickup
  point" / "Airport, port or address" instead of a bare placeholder.
- Date and Time side by side as two `FieldTile`s, showing "Thu, 1 Oct 2026" / "09:00".
- Passengers + luggage as one `FieldTile` opening the existing picker sheet.
- "+ Add return journey" as a text button that expands an inset card with return
  date/time (hampshire pattern), instead of a switch that reveals nothing until later.
- Via stops: keep, but render them inside the pickup/destination block as an indented
  row with the timeline dots (`RouteTimeline` style).
- CTA at bottom: "See prices" pinned via `BottomAction`, with the "Fixed price. No
  account needed" line under it.
- Address search sheet (`address_search_field.dart`): add the "Popular locations"
  chips from hampshire's `location_selector_modal` (Heathrow, Gatwick, cruise
  terminals…) above the recent-places list. Pure UI, sourced from a constant list.

### 2.3 Vehicle (`features/booking/vehicle_screen.dart`) — ½ day
Already the strongest screen. Small tweaks only:
- Add hampshire's "Fixed fare" `CalloutCard` between the route summary and the list
  ("£125.00 — price agreed before travel, no hidden charges").
- Selected card: gold border is fine; add the gold-tint background for the selected
  state so it reads on dark mode too.
- Keep the "Held 27:46" timer.

### 2.4 Details (`features/booking/details_screen.dart`) — ½ day
- Summary card at the top → reuse `TicketCard` (already used on Confirmation) so the
  ticket motif runs through the flow.
- Group fields under "Lead passenger" and "For your driver" section titles with
  hampshire's label-above-field treatment (`CustomTextField` idea: label, hint, helper).
- Terms line: keep; move it directly above the CTA.

### 2.5 Confirmation (`features/booking/confirmation_screen.dart`) — ½ day
- Add hampshire's **large green check + "Booking confirmed!"** hero above the ticket.
  Use `AppTheme.success`, not hampshire's hardcoded `#34A853`.
- Booking reference row with **copy icon** + snackbar ("SL-8K2M copied").
- Keep "What happens next" list and the two CTAs (Pay now / View my trips).
- Add "Back to home" as a tertiary text button.

### 2.6 Trips list (`features/trips/trips_screen.dart`) — ½ day
- Replace `TabBar` with `SegmentedTabs` (Upcoming / Past).
- Trip row: keep the date-block + timeline card (better than hampshire's icon tile),
  add a trailing chevron and "Ref: SL-8K2M" caption per hampshire.
- Empty state: illustration/icon, "No upcoming trips", "Book a transfer" CTA.

### 2.7 Trip detail (`features/trips/trip_detail_screen.dart`) — ½ day
- Already good. Add: copy-reference action, and a **"Your driver" card** placeholder
  (avatar, name, vehicle, plate, Call button) from hampshire's tracking sheet, shown
  only when the booking carries driver details. Pure UI on existing model fields; if
  the field is absent, the card is hidden.
- Keep "Request cancellation" as a destructive outlined button at the bottom.

### 2.8 Sign in (`features/auth/sign_in_screen.dart`) — ½ day
- Keep phone + OTP (do not port hampshire's email/password auth).
- Add hampshire's ambient radial-gradient glows top-left / bottom-right (gold at
  low alpha) behind the form, and a centred logo hero.
- OTP step: 6 boxed digit cells instead of a plain text field.
- Keep the "your number is only used to…" trust line.

### 2.9 Profile (`features/profile/profile_screen.dart`) — ½ day
- Add a header card with avatar initial, name, phone (staged home code has a
  profile header — reuse).
- Sections: "Your details" form, then a "Support" section with `ContactTile`s
  (Call, Email, Website) sourced from `core/links.dart`. This replaces the need for a
  separate Contact tab.
- Theme toggle row, Sign out at the bottom.

---

## Phase 3 — New screens from hampshire (1½ days)

All static content; wire via go_router under the Home branch. Data comes from a
constants file for now (`core/content.dart`), so it can be swapped for an endpoint
later without touching the widgets.

| Screen | Route | Source | Notes |
|---|---|---|---|
| Splash | shown before router, in `app.dart` | `splash_screen.dart` | Logo + tagline over the hero photo, 1.5s, then `/`. Skipped in tests. |
| Airport transfers | `/services/airport` | `airport_transfers_screen.dart` | Hero, intro copy, airport list (LHR/LGW/STN/BOH/SOU) with "from £" fares, "Get a quote" → `/book` with destination preset. |
| Cruise transfers | `/services/cruise` | `cruise_transfers_screen.dart` | Same shape; terminals list. |
| Routes & prices | `/prices` | `routes_prices_screen.dart` | Hero, filter pills (Airport / Cruise / Private hire), route rows with price, tap → `/book` preset. |
| Contact / support | folded into Profile (2.9) | `contact_support_screen.dart` | No separate tab. |

Not ported: `trip_tracking_screen.dart` (needs live driver location — backend work),
`dummy_home_screen.dart`, email/password auth, the drawer.

---

## Phase 4 — Polish and verification (1 day)

- Dark mode pass on every screen (the hero overlay and tint colours need checking).
- Update `test/screenshots/screenshots_test.dart` to cover the new screens and
  regenerate `test/screenshots/out/`.
- Extend `theme_smoke_test.dart` to pump each new screen in both themes.
- Copy hampshire's `.github/workflows/firebase-distribute.yml` into this repo and
  change the Firebase app id.
- Copy `assets/images/*.jpg` hero photos (airport, cruise, support) from hampshire
  into `assets/brand/` and convert to webp to match the existing assets.
- Delete `hampshirecab_App` once the screenshots are regenerated and reviewed.

---

## Order and total

0. Settle staged work — ½ day
1. Shared kit — 1 day
2. Home → Journey → Vehicle → Details → Confirmation → Trips → Trip detail → Sign in → Profile — ~5½ days
3. New screens — 1½ days
4. Polish, tests, CI, assets — 1 day

**≈ 9–10 working days.** Home and Journey are the two screens users see most and the
two furthest from the prototype; do them first and review before continuing.
