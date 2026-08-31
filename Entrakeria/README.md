# Entrakeria (ΕΝΤΡΑΚΕΡΙΑ)

Ancient-Greek tetrad training tracker. SwiftUI + SwiftData, no third-party deps.
Targets iPhone 12 mini, iOS 17+.

The `.xcodeproj` is generated, not committed:

```sh
cd Entrakeria && xcodegen generate && open Entrakeria.xcodeproj
```

## Layout

- `TetradGeometry.swift` — the shape equation. Pure math, no UI coupling; keep it that way.
- `SessionManager.swift` — `@Observable` state. Day index is *derived* from stored sessions,
  never remembered, so a relaunch resumes mid-tetrad.
- `Models.swift` — SwiftData models + the swappable `defaultExercises` list.
- `Views/` — ribbon, today's diamond, exercise modal.

## Known issue

Completing one exercise can cascade into the whole day being logged: a short burst of
taps on the modal produced four `ExerciseLog` rows across all four exercises instead of
one. Not yet root-caused — unclear whether it is the app or replayed simulator input.
