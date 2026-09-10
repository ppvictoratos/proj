# Entrakeria (ΕΝΤΡΑΚΕΡΙΑ)

Ancient-Greek tetrad training tracker. A 4-day self-mastery cycle combining stretching, breathing work, strength training, and active recovery.

## Features

- **Dark-themed UI** with warm gold accents and smooth animations
- **Four activity types:**
  - **STRETCH** — 12 guided stretches & mobility work (pelvic tilts → bear planks)
  - **WIM HOF** — 4-in/6-out breathing timer with animated progress
  - **EXERCISE** — Full tetrad programming + strength training exercises
  - **WALK** — Log walks with location and duration tracking
- **Navigation tests** ensure each button routes correctly
- **macOS app** ready to play with animations before iOS port

## Building

```bash
cd Entrakeria/macOS
xcodegen generate
open Entrakeia.xcodeproj
```

## What's Inside

```
Entrakeria/
├── iOS/              # Swift + SwiftData (iOS 17+, iPhone 12 mini)
├── macOS/            # SwiftUI dark-mode playground
│   ├── Colors.swift  # Dark palette (charcoal, blue, gold)
│   ├── ContentView.swift  # Navigation hub
│   ├── StretchListView.swift, WimHofView.swift, etc.
│   └── ContentViewTests.swift  # 6 passing navigation tests
└── TetradGeometry.swift  # Pure math shape engine (reused on iOS)
```

## Tech

- **Zero dependencies** — SwiftUI + SwiftData only
- **Functional style** — Pure functions for state logic
- **Dark by default** — Ignores system theme
- **Tested navigation** — Each button verified to route correctly

---

**Next:** Port this macOS playground to iOS, add logging persistence, then live with it for a week.
