# ParkWind (native iPad app)

Native SwiftUI version of ParkWind — same idea as the web version in
`../ParkWind/`, zero dependencies, five source files.

Open it in a park: it asks *"Is this your location?"*, loads the park you're
standing in (or one you pick), and draws it top-down in tilted 2.5-D with
**three stacked wind arrows** per spot — winds at 10 m / 80 m / 120 m, arrow
length = speed, color = temperature, pointing downwind. ❄️/🔥 buttons find the
coldest and warmest spots via a shade/shelter/water feels-like estimate.

Data: OpenStreetMap (Overpass) + Open-Meteo. Free, no API keys. A phone
tether is plenty.

## Build & run (on your Mac)

```sh
brew install xcodegen   # once
cd ParkWindApp
xcodegen                # generates ParkWind.xcodeproj
open ParkWind.xcodeproj
```

In Xcode: select your iPad (or an iPad simulator) as the destination, set your
personal team under Signing & Capabilities, and hit Run. A free Apple ID
personal team is enough to install on your own iPad.

## Files

- `ContentView.swift` — app entry + the location-confirm / park-picker flow
- `ParkCanvasView.swift` — the 2.5-D canvas renderer, gestures, HUD
- `API.swift` — Overpass + Open-Meteo clients
- `Models.swift` — domain types, geometry helpers, microclimate estimate
- `LocationManager.swift` — async CoreLocation wrapper
