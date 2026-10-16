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

