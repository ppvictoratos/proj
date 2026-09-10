import Foundation
import SwiftData

@Model final class TetradCycle {
    var startDate: Date
    @Relationship(deleteRule: .cascade) var sessions: [WorkoutSession]
    init(startDate: Date = .now) { self.startDate = startDate; sessions = [] }
}

@Model final class WorkoutSession {
    var dayIndex: Int
    var date: Date
    @Relationship(deleteRule: .cascade) var logs: [WorkoutLog]
    init(dayIndex: Int, date: Date = .now) {
        self.dayIndex = dayIndex; self.date = date; logs = []
    }
}

@Model final class WorkoutLog {
    var type: String // "stretch", "wim_hof", "exercise", "walk"
    var activity: String
    var location: String?
    var duration: TimeInterval
    var completedAt: Date
    init(type: String, activity: String, location: String? = nil, duration: TimeInterval = 0) {
        self.type = type; self.activity = activity; self.location = location
        self.duration = duration; self.completedAt = .now
    }
}
