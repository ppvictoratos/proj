# Nuzlocke Tracker — App Plan

## What This Is

Native Kotlin Android app for tracking Pokémon Nuzlocke runs. Primary target: **Anbernic RG Rotate**.
Dev/test on Mac (Android emulator) via Android Studio. Sync between Mac mini and MacBook Air via GitHub.
Flagship portfolio project showcasing AI integration.

---

## Current State

- `proj/nuzlocke-tracker` — existing Kotlin scaffold (Room, Jetpack Compose, no real UI yet)
- Neither Mac has Android Studio installed — **first step: install it**

---

## Core Features

### Dashboard (main screen — widgets)
- Team strip: 6 Pokémon, level + type + HP at a glance
- Next gym widget: upcoming leader, their team, your level targets
- Badge counter (0–8)
- Skull counter (deaths this run)

### Route Matrix (Encounter Log)
- Grid of all Emerald routes/areas
- Caught routes grayed out
- Tap into a route → tiny map + available mons + spawn rates
- One encounter per route rule enforced

### Greek Name Suggester (AI feature)
- On capture: generate 5 Greek name options based on the mon's type/characteristics
- "Generate new" button hits the Claude API for fresh suggestions
- Free-text override if you want to type your own
- Naming logic: Claude API nanoservice, pure functional Kotlin, called from the app
- Naming strategy: look at real-life animal/creature the mon is based on → translate/adapt to Greek

### Team Management
- Level up button (increment)
- Mark dead → archives to graveyard, removes from active team
- Box (benched) section separate from active team

### Gym Prep Advisor
- Hardcoded Emerald gym data: leader name, team, levels, recommended level caps
- Type coverage suggestions vs. leader's team
- Prep checklist (healing items, training targets)

### Graveyard
- Archive of all dead mons, where they were lost

---

## AI Nanoservice

- **Claude API** (not a trained model from scratch)
- Tiny functional Kotlin service: takes `{mon_name, types[], real_creature}` → returns `[name1...name5]`
- Stateless, pure function — easy to test, easy to reuse
- This is the "AI showcase" piece for portfolio

---

## Tech Stack

- **Language:** Kotlin
- **UI:** Jetpack Compose
- **Persistence:** Room (SQLite)
- **Async:** Kotlin Coroutines
- **AI:** Claude API (Anthropic SDK or plain HTTP)
- **Build:** Gradle (existing `build.gradle.kts`)
- **IDE:** Android Studio (to install)

---

## Data Models (existing in `data/models.kt`)

```kotlin
// Extend these as needed
data class Pokemon(
  val id: String,
  val name: String,           // Greek-themed, 10 char limit
  val types: List<String>,
  val level: Int,
  val location: String,       // route caught
  val status: Status,         // ALIVE | DEAD | BOX
  val hpCurrent: Int,
  val hpMax: Int,
  val moves: List<String> = emptyList()
)

enum class Status { ALIVE, DEAD, BOX }

data class RunState(
  val badges: Int,
  val currentLocation: String,
  val activeTeam: List<Pokemon>,
  val box: List<Pokemon>,
  val graveyard: List<Pokemon>,
  val notes: Map<String, String>
)
```

---

## Dev Setup (to do)

1. Install Android Studio on Mac mini (primary) and MacBook Air
2. Push `proj/nuzlocke-tracker` to GitHub
3. Configure Android emulator on each machine
4. Get USB debugging working on Anbernic RG Rotate for direct deploy

---

## Build Order (MVP)

1. Android Studio setup + GitHub remote
2. Dashboard shell (empty widgets, nav skeleton)
3. Team management (add/level/kill)
4. Route matrix (static Emerald data)
5. Gym prep advisor (hardcoded Emerald data)
6. Greek name suggester (Claude API nanoservice)
7. Stats / graveyard view
8. Polish + deploy APK to Anbernic

---

## Notes

- Emerald run active now — data fixtures start with Emerald, design for multi-game later
- Portfolio angle: clean architecture, AI nanoservice, functional style
- No React/web version planned — native Android only
