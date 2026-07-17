# Nuzlocke Tracker

A Kotlin/Android app to track Pokémon Nuzlocke runs.

## Structure

- `src/main/kotlin/MainActivity.kt` — App entry point, compose navigation
- `src/main/kotlin/data/models.kt` — Data models (NuzlockeRun, TeamMember, enums)
- `build.gradle.kts` — Dependencies and build config

## Next Steps

1. Create `NuzlockeDao` for database operations
2. Create `NuzlockeRepository` for data access
3. Build UI screens:
   - Run list/home
   - Create new run
   - Team management (add/edit/remove members)
   - Run details view
4. Add ViewModel to manage state

## Feature Ideas

- **Basic tracking:** Log runs, team members, casualties
- **Pacing (optional):** Show next gym leaders/story beat + expected levels
- **Stats:** Survival rate per gym, average team level, etc.
- **Export:** Save run data as JSON backup

## Setup

This uses:
- **Room** for SQLite persistence
- **Jetpack Compose** for UI
- **Kotlin Coroutines** for async data ops

Run with Android Studio or command line with `./gradlew build`.
