# Marg — Proof of Work

Append one block per phase. Evidence = commit, log, screenshot. Keep it factual.

## Template
```
### Phase N — <name>  (<date>)
- Commit / tag: <hash> / phase-N
- Changed: <3 bullets max>
- Verify: proof/phase-N.log  (analyze: clean | tests: X passed)
- Screenshot: proof/phase-N-<screen>.png  (vs design-reference/screens/<ref>.png)
- Deviations from design + why: <none | …>
```

## Log
### Phase D — Design (HTML/CSS reference)  (2026-10-14)
- Output: `design-reference/html/index.html` + `marg.css`, 8 screens rendered to `design-reference/screens/`.
- Verify: rendered headlessly with Chromium at 1900 px; all 8 screens visually inspected.
- Deviations: iPhone frames used for the Apple look in the assignment; Flutter build uses Android insets and 48 dp targets.

### Phase 0 — Recon & scaffold  (2026-10-16)
- Commit / tag: phase-0
- Changed:
  - Verified Flutter Android toolchain and booted Android emulator (API 37).
  - Scaffolded Flutter project with Riverpod, GoRouter, Dio, FlutterMap, Geolocator, Inter fonts.
  - Configured minSdk 26, edge-to-edge, predictive back, location permissions, and Marg tokens.
- Verify: proof/phase-0.log  (analyze: clean | tests: 8 passed)
- Screenshot: proof/phase-0-scaffold.png  (vs design-reference/screens/welcome.png)
- Deviations from design + why: none

### Phase 1 — Foundation  (2026-10-16)
- Commit / tag: phase-1
- Changed:
  - Saved 4 endpoint JSON fixtures in `test/fixtures/` and verified tolerant parsing with `FakeTransitRepository`.
  - Built typed API client with timeout/retry/errors (`Offline`, `Unavailable503`, `Timeout`) and Riverpod providers.
  - Implemented 9 token-based shared widgets with passing light & dark golden tests (31 tests total).
- Verify: proof/phase-1.log  (analyze: clean | tests: 31 passed)
- Screenshot: proof/phase-1-foundation.png  (vs design-reference/screens/welcome.png)
- Deviations from design + why: none

### Phase 2 — Shell + Explore  (2026-10-17)
- Commit / tag: edfaef0 / phase-2
- Changed:
  - Built onboarding flow with 3 value props, location rationale, lazy location permission request via Geolocator, and SharedPreferences single-show persistence.
  - Built full-bleed FlutterMap with working tile config, user location dot with soft halo, stop markers with labels, unified top-right glass action buttons (locate-me + layers), and full-bleed glass tab bar with 48dp targets.
  - Built modular Explore DraggableScrollableSheet (snaps 0.14/0.5/0.92) with "Where to?" field, 52dp circular shortcuts (Home/Work/Add), and nearby stops list with haversine distance, line chips, ETAs, and skeleton/empty/error states.
- Verify: proof/phase-2.log  (analyze: clean | tests: 31 passed | 0 hardcoded colors)
- Screenshot: proof/phase-2-home.png  (vs design-reference/screens/home.png), proof/phase-2-welcome.png (vs design-reference/screens/welcome.png)
- Deviations from design + why: none; Android 48dp touch targets and predictive back preserved.

### Phase 8 — UI Design Implementation in Application  (2026-10-16)
- Commit / tag: phase-8
- Changed:
  - Implemented all 8 screens in Flutter (pump/mobile): Welcome, Explore, Plan, Results, Itinerary, Live, Saved, Alerts.
  - Implemented tokens, glass effects, shared chips, segmented control, routing with go_router, state management with Riverpod.
  - Connected transit repository, search, geocoding, route ranking, SharedPreferences persistence.
- Verify: proof/phase-8.log (analyze: clean | tests: 8 passed | 0 hardcoded colors)
- Screenshots: proof/welcome_running.png, proof/explore_running.png (vs design-reference/screens/00_overview.png)
- Running App: Active at http://localhost:3000/
- Deviations from design + why: none; Android 48dp touch targets and predictive back applied.

