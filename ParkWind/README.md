# ParkWind 🌳💨

A top-down park viewer for iPad. Open it in a park (tethered to your phone is
plenty — it's a few small API calls), confirm your location, and see the park
rendered in tilted 2.5-D with **three stacked wind arrows** at every sample
spot — winds at 10 m, 80 m and 120 m. Arrow **direction** points downwind,
**length** is speed, **color** is temperature. Buttons find the **coldest** and
**warmest** spots in the park.

## How to use it on your iPad

1. Open the hosted URL in Safari (HTTPS is required for geolocation).
2. Tap **Share ▸ Add to Home Screen** — it then launches full-screen like a
   native app.
3. On open: *"Is this your location?"* → **Yes!** loads the nearest park, or
   **No — pick another** shows nearby parks plus a search box.
4. In the park view:
   - one finger drags to pan, pinch zooms, twist rotates, tap a marker for
     details
   - **❄️ Coldest / 🔥 Warmest** highlight the best spot
   - **2D/3D** toggles pure top-down vs. tilted view
   - **°C/°F** switches units (auto-detected from your locale)

## Data sources (free, no API keys)

- **OpenStreetMap / Overpass API** — park boundaries, trees, water, woods,
  paths, buildings.
- **Open-Meteo** — wind speed/direction and temperature at 10 m, 80 m and
  120 m, plus apparent temperature.

### About "coldest / warmest"

Forecast models are km-scale, so raw temperatures barely differ across one
park. ParkWind therefore estimates a per-spot *feels-like*: spots sheltered by
trees recover part of the wind chill, tree shade cools in daytime sun, and
water edges run slightly cool. It's an estimate, not a measurement — but it
points you at the right corner of the park.

## Hosting

It's one static folder — host it anywhere that serves HTTPS:

```sh
npx http-server ParkWind        # local test (geolocation needs localhost/HTTPS)
```

or drop the folder into Vercel / Netlify / GitHub Pages.

## Development

No build step, no dependencies — everything lives in `index.html`.
`icon.png` + `manifest.webmanifest` make it installable to the home screen.
