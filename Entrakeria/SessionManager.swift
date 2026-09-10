import Foundation
import Observation
import SwiftData

enum VertexState { case locked, active, done }

@Observable final class SessionManager {
    var activeCycle: TetradCycle?
    var activeSession: WorkoutSession?
    var activeDayIndex: Int = 0
    var activeExercise: Exercise?
    var elapsed: TimeInterval = 0     // stopwatch, counts up
    var laps: [TimeInterval] = []     // one lap per rep
    var isRunning = false

    let exercises: [Exercise] = defaultExercises

    // MARK: - Pure functions

    /// Names logged in the current session — the source of truth for vertex state.
    private var completedNames: Set<String> {
        Set((activeSession?.logs ?? []).map(\.exerciseName))
    }

    /// Sequential unlock: done → active (first unlogged) → locked.
    func state(at index: Int) -> VertexState {
        let done = completedNames
        if done.contains(exercises[index].name) { return .done }
        let firstOpen = exercises.firstIndex { !done.contains($0.name) }
        return index == firstOpen ? .active : .locked
    }

    /// One stopwatch tick. Pure: elapsed + delta.
    static func tick(_ elapsed: TimeInterval, by delta: TimeInterval) -> TimeInterval {
        elapsed + delta
    }

    func tick(by delta: TimeInterval) {
        guard isRunning else { return }
        elapsed = Self.tick(elapsed, by: delta)
    }

    /// Total days laid out on the ribbon: four per stored cycle, at least one tetrad.
    static func ribbonDays(cycleCount: Int) -> Int { max(4, cycleCount * 4) }

    // MARK: - SwiftData

    /// Resolves cycle, day, and session from what is stored — the day index is derived,
    /// never remembered, so a relaunch resumes exactly where the tetrad left off.
    func bootstrap(in context: ModelContext) {
        let cycle = activeCycle ?? latestCycle(in: context)

        guard let resume = firstIncompleteDay(in: cycle) else {
            // Tetrad finished: open the next cycle and resolve against that instead.
            let next = TetradCycle()
            context.insert(next)
            activeCycle = next
            activeSession = nil
            return bootstrap(in: context)
        }

        activeCycle = cycle
        activeDayIndex = resume
        if let existing = cycle.sessions.first(where: { $0.dayIndex == resume }) {
            activeSession = existing
        } else {
            let s = WorkoutSession(dayIndex: resume)
            context.insert(s)
            cycle.sessions.append(s)
            activeSession = s
        }
    }

    private func latestCycle(in context: ModelContext) -> TetradCycle {
        let stored = (try? context.fetch(FetchDescriptor<TetradCycle>())) ?? []
        if let last = stored.sorted(by: { $0.startDate < $1.startDate }).last { return last }
        let fresh = TetradCycle()
        context.insert(fresh)
        return fresh
    }

    /// First day 0...3 that still has unlogged exercises, or nil when the tetrad is done.
    private func firstIncompleteDay(in cycle: TetradCycle) -> Int? {
        (0...3).first { day in
            let logs = cycle.sessions.first { $0.dayIndex == day }?.logs ?? []
            return Set(logs.map(\.exerciseName)).count < exercises.count
        }
    }

    func select(_ exercise: Exercise) {
        activeExercise = exercise
        elapsed = 0
        laps = []
        isRunning = false
    }

    func start() { isRunning = true }

    /// Marks one rep at the current split. Stops on its own at the target count.
    func lap() {
        guard isRunning, laps.count < (activeExercise?.reps ?? 0) else { return }
        laps.append(elapsed)
        if laps.count == activeExercise?.reps { isRunning = false }
    }

    /// Logs the exercise, then re-derives the day — which rolls the tetrad over when day 4 closes.
    func completeExercise(_ exercise: Exercise, in context: ModelContext) {
        bootstrap(in: context)
        guard let session = activeSession else { return }

        // Log what was actually done, not what was prescribed.
        let done = laps.count
        let log = ExerciseLog(exerciseName: exercise.name,
                              reps: done,
                              duration: elapsed)
        log.completedAt = .now
        context.insert(log)
        session.logs.append(log)
        session.totalDuration += elapsed

        activeExercise = nil
        elapsed = 0
        laps = []
        isRunning = false

        // Autosave alone can lose a rep if the app dies right after; a set is worth a flush.
        try? context.save()

        bootstrap(in: context)
    }
}
