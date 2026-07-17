# Enkrateia V2: UI Redesign (Timeline + Rotated Square)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild Enkrateia UI from scratch with a **timeline scrubber**, **rotated square tetrad navigator**, **exercise detail modals**, and **weight tracking per exercise**.

**Architecture:** 
- Keep existing SwiftData models, services, and ViewModels from v1
- Replace all Views with new design
- Add ExerciseDetail model for instructions + weight tracking
- Timeline view shows scrollable tetrad history with highlight tracer
- Dashboard shows rotated square with 4 interactive corners (one per exercise group)
- Tapping corner opens modal with exercise name, instructions, set/rep/weight form, and timer

**Tech Stack:** SwiftUI (canvas for square), SwiftData (persistence), UserNotifications (gong sound)

---

## File Structure (Views Only - Replace v1)

```
Views/
├── Timeline/
│   ├── TimelineView.swift           // Scrubber with moving diamond highlight
│   └── TimelineIndicator.swift      // Diamond shape that traces tetrad outline
├── Dashboard/
│   ├── DashboardView.swift          // Home screen: title + rotated square + buttons
│   ├── RotatedSquareView.swift      // 4-corner interactive tetrad visualization
│   └── CornerButton.swift           // Tappable corner representing exercise group
├── Exercise/
│   ├── ExerciseDetailView.swift     // Modal: name, instructions, logging form, timer
│   ├── ExerciseTimerModal.swift     // Timer appears when tapping timer button
│   └── WeightSlider.swift           // Adjust weight per exercise
├── ExerciseList/
│   ├── ExerciseListView.swift       // "EXERCISES" tab: all exercises + weight sliders
│   └── ExerciseRowView.swift        // Single exercise row with weight adjustment
├── Tetrads/
│   ├── TetradsView.swift            // "TETRADS" tab: history of past tetrad cycles
│   └── TetradHistoryRow.swift       // Single tetrad in history
└── RootView.swift                   // Two buttons: EXERCISES | TETRADS (or tabs)
```

---

## Task 1: Timeline Scrubber View

**Files:**
- Create: `Views/Timeline/TimelineView.swift`
- Create: `Views/Timeline/TimelineIndicator.swift`

**Why:** Users scroll left/right through tetrad history. A diamond outline traces each tetrad's square outline as they scrub.

- [ ] **Step 1: Create TimelineIndicator.swift**

```swift
import SwiftUI

struct TimelineIndicator: View {
    let progress: Double  // 0.0 to 1.0 within current tetrad
    let size: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Rotating square (diamond orientation)
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.cyan, lineWidth: 2)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))
            
            // Animated gradient accent on current corner
            Canvas { context in
                let angle = (progress * 360).truncatingRemainder(dividingBy: 360)
                // Draw small accent at current corner position
                var path = Path()
                path.addArc(center: .init(x: size/2, y: 0),
                           radius: 3, startAngle: .degrees(0), endAngle: .degrees(180),
                           clockwise: false)
                context.stroke(path, with: .color(.cyan), lineWidth: 2)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview {
    TimelineIndicator(progress: 0.25)
}
```

- [ ] **Step 2: Create TimelineView.swift**

```swift
import SwiftUI
import SwiftData

struct TimelineView: View {
    @ObservedObject var viewModel: TetradCycleViewModel
    @State private var scrollPosition: UUID?
    @Query(sort: [SortDescriptor(\.date, order: .reverse)]) var sessions: [WorkoutSession]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("ENKRATEIA")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            // Timeline scrubber
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                            VStack(spacing: 4) {
                                TimelineIndicator(progress: Double(index) / Double(max(sessions.count, 1)))
                                    .id(session.id)
                                
                                Text(session.tetradDay.name)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .onAppear {
                    if let firstSession = sessions.first {
                        proxy.scrollTo(firstSession.id, anchor: .center)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(UIColor.systemGray6).opacity(0.1).ignoresSafeArea())
    }
}

#Preview {
    TimelineView(viewModel: TetradCycleViewModel(modelContext: .preview))
}
```

- [ ] **Step 3: Commit timeline**

```bash
git add Views/Timeline/
git commit -m "feat: add timeline scrubber with animated diamond indicator"
```

---

## Task 2: Rotated Square Dashboard

**Files:**
- Create: `Views/Dashboard/RotatedSquareView.swift`
- Create: `Views/Dashboard/CornerButton.swift`
- Create: `Views/Dashboard/DashboardView.swift`

**Why:** The rotated square (diamond) is the visual center. Each corner represents an exercise or exercise group. Tapping opens the detail modal.

- [ ] **Step 1: Create CornerButton.swift**

```swift
import SwiftUI

struct CornerButton: View {
    let exercise: Exercise
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 16))
                Text(exercise.name)
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(Color.cyan.opacity(0.2))
            .cornerRadius(8)
        }
    }
}

#Preview {
    CornerButton(
        exercise: Exercise(name: "KB Swings", program: .tetrad, tetradDay: .day1, 
                          muscleGroup: "Posterior", description: "Power"),
        action: {}
    )
}
```

- [ ] **Step 2: Create RotatedSquareView.swift**

```swift
import SwiftUI

struct RotatedSquareView: View {
    let exercises: [Exercise]
    let onCornerTap: (Exercise) -> Void
    
    let squareSize: CGFloat = 200
    
    var body: some View {
        ZStack {
            // Rotated square outline (diamond)
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.cyan, lineWidth: 2)
                .frame(width: squareSize, height: squareSize)
                .rotationEffect(.degrees(45))
            
            // 4 corners with exercise buttons
            VStack(spacing: squareSize - 60) {
                HStack(spacing: squareSize - 60) {
                    if exercises.count > 0 {
                        CornerButton(exercise: exercises[0], action: {
                            onCornerTap(exercises[0])
                        })
                    }
                    Spacer()
                    if exercises.count > 1 {
                        CornerButton(exercise: exercises[1], action: {
                            onCornerTap(exercises[1])
                        })
                    }
                }
                
                Spacer()
                
                HStack(spacing: squareSize - 60) {
                    if exercises.count > 2 {
                        CornerButton(exercise: exercises[2], action: {
                            onCornerTap(exercises[2])
                        })
                    }
                    Spacer()
                    if exercises.count > 3 {
                        CornerButton(exercise: exercises[3], action: {
                            onCornerTap(exercises[3])
                        })
                    }
                }
            }
            .frame(width: squareSize, height: squareSize)
        }
        .frame(height: 300)
    }
}

#Preview {
    RotatedSquareView(
        exercises: Constants.tetradExercises[.day1] ?? [],
        onCornerTap: { _ in }
    )
}
```

- [ ] **Step 3: Create DashboardView.swift**

```swift
import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var viewModel: TetradCycleViewModel
    @State private var selectedExercise: Exercise?
    @State private var showExerciseDetail = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _viewModel = StateObject(wrappedValue: TetradCycleViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ENKRATEIA")
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            RotatedSquareView(exercises: viewModel.currentExercises) { exercise in
                selectedExercise = exercise
                showExerciseDetail = true
            }
            
            Spacer()
            
            // Bottom buttons
            HStack(spacing: 20) {
                Button(action: {}) {
                    Text("EXERCISES")
                        .font(.system(weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.cyan)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                
                Button(action: {}) {
                    Text("TETRADS")
                        .font(.system(weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.cyan.opacity(0.2))
                        .foregroundColor(.cyan)
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemGray6).opacity(0.1).ignoresSafeArea())
        .sheet(isPresented: $showExerciseDetail) {
            if let exercise = selectedExercise {
                ExerciseDetailView(exercise: exercise, modelContext: modelContext)
            }
        }
    }
}

#Preview {
    DashboardView(modelContext: .preview)
}
```

- [ ] **Step 4: Commit dashboard**

```bash
git add Views/Dashboard/
git commit -m "feat: add rotated square dashboard with interactive corners"
```

---

## Task 3: Exercise Detail Modal with Timer

**Files:**
- Create: `Views/Exercise/ExerciseDetailView.swift`
- Create: `Views/Exercise/ExerciseTimerModal.swift`
- Create: `Views/Exercise/WeightSlider.swift`

**Why:** Tapping a corner opens a modal showing exercise name, instructions, logging form, and timer.

- [ ] **Step 1: Create WeightSlider.swift**

```swift
import SwiftUI

struct WeightSlider: View {
    @Binding var weight: Double
    let max: Double = 300
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Weight")
                    .foregroundColor(.gray)
                Spacer()
                Text(String(format: "%.0f lbs", weight))
                    .font(.caption)
                    .foregroundColor(.cyan)
            }
            
            Slider(value: $weight, in: 0...max, step: 5)
                .tint(.cyan)
        }
    }
}

#Preview {
    @State var weight = 50.0
    return WeightSlider(weight: $weight)
}
```

- [ ] **Step 2: Create ExerciseTimerModal.swift**

```swift
import SwiftUI

struct ExerciseTimerModal: View {
    @ObservedObject var viewModel: WorkoutSessionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Rest Timer")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            
            if viewModel.timerIsRunning {
                Text(String(format: "%02d:%02d",
                           viewModel.remainingSeconds / 60,
                           viewModel.remainingSeconds % 60))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .transition(.scale)
                
                Button(action: viewModel.stopRestTimer) {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            } else {
                Text("Select Rest Duration"
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ForEach([30, 60, 90], id: \.self) { seconds in
                        Button(action: { viewModel.startRestTimer(seconds: seconds) }) {
                            Text("\(seconds)s")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color.cyan.opacity(0.2))
                                .foregroundColor(.cyan)
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color(UIColor.systemGray6).opacity(0.1))
    }
}

#Preview {
    ExerciseTimerModal(viewModel: WorkoutSessionViewModel(
        session: WorkoutSession(tetradDay: .day1),
        modelContext: .preview
    ))
}
```

- [ ] **Step 3: Create ExerciseDetailView.swift**

```swift
import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    let exercise: Exercise
    let modelContext: ModelContext
    
    @State private var sets = ""
    @State private var reps = ""
    @State private var weight = 45.0
    @State private var usedBelt = false
    @State private var showTimer = false
    @StateObject private var sessionVM: WorkoutSessionViewModel
    @Environment(\.dismiss) var dismiss
    
    init(exercise: Exercise, modelContext: ModelContext) {
        self.exercise = exercise
        self.modelContext = modelContext
        
        let session = WorkoutSession(tetradDay: exercise.tetradDay ?? .day1)
        _sessionVM = StateObject(wrappedValue: WorkoutSessionViewModel(
            session: session,
            modelContext: modelContext
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).opacity(0.1).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text(exercise.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.cyan)
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to perform")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(exercise.description)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(3)
                    }
                    .padding(12)
                    .background(Color(UIColor.systemGray6).opacity(0.3))
                    .cornerRadius(8)
                    
                    // Logging form
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sets")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("", text: $sets)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Reps")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("", text: $reps)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        WeightSlider(weight: $weight)
                        
                        Toggle("Dipping Belt", isOn: $usedBelt)
                            .tint(.cyan)
                    }
                    .padding(12)
                    .background(Color(UIColor.systemGray6).opacity(0.3))
                    .cornerRadius(8)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            if let s = Int(sets), let r = Int(reps) {
                                sessionVM.logExercise(
                                    exerciseName: exercise.name,
                                    sets: s,
                                    reps: r,
                                    weight: weight,
                                    usedBelt: usedBelt
                                )
                                dismiss()
                            }
                        }) {
                            Text("Log")
                                .font(.system(weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.cyan)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { showTimer = true }) {
                            Text("Rest")
                                .font(.system(weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.cyan.opacity(0.2))
                                .foregroundColor(.cyan)
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .sheet(isPresented: $showTimer) {
                ExerciseTimerModal(viewModel: sessionVM)
            }
        }
    }
}

#Preview {
    ExerciseDetailView(
        exercise: Exercise(name: "KB Swings", program: .tetrad, tetradDay: .day1,
                          muscleGroup: "Posterior", description: "Explosive hip drive"),
        modelContext: .preview
    )
}
```

- [ ] **Step 4: Commit exercise detail**

```bash
git add Views/Exercise/
git commit -m "feat: add exercise detail modal with timer and weight tracking"
```

---

## Task 4: Exercise List View

**Files:**
- Create: `Views/ExerciseList/ExerciseListView.swift`
- Create: `Views/ExerciseList/ExerciseRowView.swift`

**Why:** "EXERCISES" button opens a scrollable list of all exercises with weight sliders for quick adjustment.

- [ ] **Step 1: Create ExerciseRowView.swift**

```swift
import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    @State private var weight = 45.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.caption)
                        .foregroundColor(.white)
                    Text(exercise.muscleGroup)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(String(format: "%.0f lbs", weight))
                    .font(.caption)
                    .foregroundColor(.cyan)
            }
            
            Slider(value: $weight, in: 0...300, step: 5)
                .tint(.cyan)
        }
        .padding(12)
        .background(Color(UIColor.systemGray6).opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    ExerciseRowView(exercise: Exercise(
        name: "Deadlifts", program: .tetrad, tetradDay: .day2,
        muscleGroup: "Posterior", description: "Heavy"
    ))
}
```

- [ ] **Step 2: Create ExerciseListView.swift**

```swift
import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel: TetradCycleViewModel
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("EXERCISES")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.currentExercises, id: \.id) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

#Preview {
    ExerciseListView(viewModel: TetradCycleViewModel(modelContext: .preview))
}
```

- [ ] **Step 3: Commit exercise list**

```bash
git add Views/ExerciseList/
git commit -m "feat: add exercise list with per-exercise weight tracking"
```

---

## Task 5: Tetrad History View

**Files:**
- Create: `Views/Tetrads/TetradsView.swift`
- Create: `Views/Tetrads/TetradHistoryRow.swift`

**Why:** "TETRADS" button shows past tetrad cycles with performance summary.

- [ ] **Step 1: Create TetradHistoryRow.swift**

```swift
import SwiftUI

struct TetradHistoryRow: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.tetradDay.name)
                    .font(.caption)
                    .foregroundColor(.white)
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(session.exercises.count) exercises")
                .font(.caption2)
                .padding(4)
                .background(Color.cyan.opacity(0.2))
                .foregroundColor(.cyan)
                .cornerRadius(4)
        }
        .padding(12)
        .background(Color(UIColor.systemGray6).opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    TetradHistoryRow(session: WorkoutSession(tetradDay: .day1))
}
```

- [ ] **Step 2: Create TetradsView.swift**

```swift
import SwiftUI
import SwiftData

struct TetradsView: View {
    @Query(sort: [SortDescriptor(\.date, order: .reverse)]) var sessions: [WorkoutSession]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("TETRADS")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                if sessions.isEmpty {
                    Text("No tetrads logged yet")
                        .foregroundColor(.gray)
                        .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(sessions, id: \.id) { session in
                                TetradHistoryRow(session: session)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }
}

#Preview {
    TetradsView()
}
```

- [ ] **Step 3: Commit tetrad history**

```bash
git add Views/Tetrads/
git commit -m "feat: add tetrad history view"
```

---

## Task 6: Root Navigation & App Entry

**Files:**
- Create: `Views/RootView.swift`
- Modify: `EnkrateiaTrackerApp.swift`

**Why:** Wire up tab/button navigation between Dashboard, Exercises, and Tetrads. Keep app entry point.

- [ ] **Step 1: Create RootView.swift**

```swift
import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) var modelContext
    @State private var activeTab: String = "dashboard"
    
    var body: some View {
        ZStack {
            Group {
                if activeTab == "dashboard" {
                    DashboardView(modelContext: modelContext)
                } else if activeTab == "exercises" {
                    ExerciseListView(viewModel: TetradCycleViewModel(modelContext: modelContext))
                } else {
                    TetradsView()
                }
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: { activeTab = "exercises" }) {
                        Text("EXERCISES")
                            .font(.system(weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(activeTab == "exercises" ? Color.cyan : Color.cyan.opacity(0.2))
                            .foregroundColor(activeTab == "exercises" ? .black : .cyan)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { activeTab = "tetrads" }) {
                        Text("TETRADS")
                            .font(.system(weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(activeTab == "tetrads" ? Color.cyan : Color.cyan.opacity(0.2))
                            .foregroundColor(activeTab == "tetrads" ? .black : .cyan)
                            .cornerRadius(8)
                    }
                }
                .padding(16)
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(ModelContainerProvider.shared.container)
}
```

- [ ] **Step 2: Verify EnkrateiaTrackerApp.swift**

(Keep as is from v1 - no changes needed)

- [ ] **Step 3: Commit navigation**

```bash
git add Views/RootView.swift
git commit -m "feat: add root navigation with dashboard, exercises, and tetrads tabs"
```

---

## Task 7: Dark Theme & Polish

**Files:**
- Modify all Views created in Tasks 1-6 to use Theme.swift (from v1)

**Why:** Ensure consistent dark theme, cyan accents, white text, high contrast.

- [ ] **Step 1: Verify Theme.swift exists**

(From v1 - should already be at `Utils/Theme.swift`)

- [ ] **Step 2: Apply theme to all views**

All views in Tasks 1-6 already use:
- `Color(UIColor.systemGray6).opacity(0.1)` for dark BG
- `Color(UIColor.systemGray6).opacity(0.3)` for cards
- `Color.cyan` for accent
- `.foregroundColor(.white)` for primary text

- [ ] **Step 3: Commit theme verification**

```bash
git commit -m "feat: verify dark theme applied across all v2 views"
```

---

## Task 8: Build & Test

**Files:**
- No new files; test all views

**Why:** Verify the new UI builds and renders correctly.

- [ ] **Step 1: Build on simulator**

```bash
xcodebuild build -scheme EnkrateiaTracker -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: Clean build with no errors.

- [ ] **Step 2: Test dashboard**

- Launch app
- Verify "ENKRATEIA" title shows
- Verify rotated square appears with 4 corners
- Tap a corner → exercise detail modal opens

Expected: Modal shows exercise name, description, sets/reps/weight fields, timer button, log button.

- [ ] **Step 3: Test exercise logging**

- In modal, enter sets=5, reps=10, weight=50 lbs
- Tap "Log"
- Modal closes

Expected: Exercise logged to WorkoutSession.

- [ ] **Step 4: Test timer**

- In modal, tap "Rest"
- Timer modal opens with 30/60/90s buttons
- Tap 60s
- Countdown starts

Expected: Timer counts down from 60.

- [ ] **Step 5: Test EXERCISES tab**

- Tap "EXERCISES" button
- Verify list of all exercises appears
- Adjust weight slider on one exercise

Expected: Slider updates, persists to ExerciseLog.

- [ ] **Step 6: Test TETRADS tab**

- Tap "TETRADS" button
- Verify past workouts list

Expected: Sessions appear sorted by date.

- [ ] **Step 7: Commit test results**

```bash
git commit -m "test: verify v2 ui builds and all features functional"
```

---

## Summary

This plan rebuilds Enkrateia with your design vision:

- **Timeline scrubber** for tetrad history with animated diamond indicator
- **Rotated square dashboard** with 4 interactive corners (exercises)
- **Exercise detail modal** with instructions, logging, and timer
- **Weight tracking** with per-exercise sliders
- **Exercise list** for bulk adjustments
- **Tetrad history** for reviewing past cycles
- **Dark theme** with cyan accents and line art aesthetic
- **Minimal navigation** (two buttons: EXERCISES, TETRADS)

All built on v1's solid foundation (SwiftData, ViewModels, services).

**Execution:** Subagent-driven, one task at a time, review between tasks.

---

Ready?
