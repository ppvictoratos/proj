import Foundation
import SwiftData

@Model
final class TetradCycle {
    var startDate: Date
    var currentDay: TetradDay

    init(startDate: Date = Date(), currentDay: TetradDay = .day1) {
        self.startDate = startDate
        self.currentDay = currentDay
    }

    func advanceDay() {
        currentDay = currentDay.nextDay
    }
}
