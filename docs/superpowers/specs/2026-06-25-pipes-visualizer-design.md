# macOS Music Visualizer: Pipes Screensaver Design

**Date:** 2026-06-25  
**Author:** ppvictoratos  
**Status:** Approved

## Overview

A desktop pet project that visualizes MP3 playback in the style of the Windows 95 Pipes screensaver with a warm hacker terminal aesthetic. Dark greenish-black background with amber/orange glowing pipes, reminiscent of old CRT monitors.

## User Experience

### Startup State
- App launches to an empty black screen
- Prompt text: "Drop an MP3 here or press ⌘O to open"
- Ready to accept files

### File Loading
**Drag-Drop:** Drop an MP3 onto the app window → file loads and displays filename/duration → user must press Space to play

**File Picker:** Press ⌘O → standard macOS file picker → select an MP3 → auto-starts playback immediately

### Playback
- Visible playback controls at the bottom: play/pause button, scrub bar, time display (current / total)
- Window is resizable and windowed (not fullscreen)
- Stays on desktop as a persistent pet project

## Visualization — Three Programs

Press **P** to cycle through programs. Each responds differently to audio.

### Program 1: Beat-Driven
- Pipes spawn and change direction on detected drum beats/transients
- Overall energy level (RMS or amplitude) controls:
  - Pipe thickness
  - Animation speed
  - Glow intensity
- Creates reactive, rhythmic visual tied to the beat

### Program 2: Frequency-Band Driven
- Screen divided into three zones (left, center, right) or more granular bands
- Each zone/band responds to a different frequency range:
  - **Bass** (left/low): 20–250 Hz
  - **Mids** (center): 250–4000 Hz
  - **Treble** (right/high): 4000+ Hz
- Pipe height/length/density grows/shrinks with frequency magnitude
- Creates a spectrum-analyzer feel

### Program 3: Hybrid
- Combines both approaches
- Beat detection drives spawning and direction changes
- Frequency bands modulate the appearance (thickness, color, glow)
- Most visually complex and layered

## Controls

| Key | Action |
|-----|--------|
| `P` | Cycle through visualization programs (1 → 2 → 3 → 1) |
| `Space` | Play / Pause |
| `→` | Scrub forward (5 or 10 seconds) |
| `←` | Scrub backward (5 or 10 seconds) |
| `⌘O` | Open file picker |
| `⌘Q` | Quit app |

## Visual Aesthetic

**Color Palette:**
- Background: Deep greenish-black (e.g., `#0a1a1a` or similar)
- Primary glow: Warm amber/orange (e.g., `#FF8800`, `#FFA500`)
- Secondary accents: Slightly cooler amber or green highlights for depth
- Bloom/glow effect to simulate CRT phosphor glow

**Pipe Design:**
- Glowing tubes with smooth rounded corners
- Blend modes and opacity to create layered, overlapping visuals
- Animated trails or fading as pipes move
- Subtle noise/grain texture optional for retro feel

**Overall Feel:**
- Warm, inviting hacker aesthetic
- Like looking at old terminal screens or CRT monitors
- Nostalgic but polished

## Technical Architecture (High-Level)

### Components
1. **Audio Engine** — Load MP3, extract audio data, provide playback controls
2. **Audio Analysis** — Real-time FFT analysis for frequency bands, beat detection for transients
3. **Visualization Engine** — Three separate visualization programs, receive audio data and output graphics
4. **UI Controller** — File loading, playback controls, program cycling
5. **Renderer** — SwiftUI Canvas or Metal for high-performance rendering

### Data Flow
```
MP3 File → Audio Engine → Audio Buffer
                        ↓
                  Audio Analysis
                  (FFT + Beat Detection)
                        ↓
                  Audio Metrics (frequencies, beat flag, energy)
                        ↓
                  Visualization Program (1/2/3)
                        ↓
                  Render Pipes
                        ↓
                  Display
```

## Success Criteria

✅ App launches and displays empty ready state  
✅ Can drag-drop an MP3 and load it  
✅ Can use file picker to open an MP3  
✅ Playback controls (play/pause/scrub) work  
✅ P key cycles through three visualization programs  
✅ Each program responds correctly to audio data  
✅ Visual aesthetic matches warm hacker CRT feel  
✅ Performance is smooth (60 FPS) during playback  
✅ Can build and run on macOS 12+

## Scope & Constraints

- **macOS only** — target macOS 12 or later
- **MP3 playback** — support MP3 format; can extend to other formats later
- **Single window** — no menu bar extras or dock features initially
- **No library/playlist management** — load one file at a time
- **No audio effects** — visualization only, music plays as-is
- **No export/recording** — visualization is for viewing only

## Out of Scope (Future)

- Playlist management
- Equalizer or audio effects
- Visualization export/recording
- Other audio formats (FLAC, WAV, etc.) — can add later
- Multiple windows/workspaces
- Settings/preferences (for now)
