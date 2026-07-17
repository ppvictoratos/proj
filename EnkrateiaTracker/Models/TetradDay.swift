import Foundation

enum TetradDay: Int, Codable, Hashable {
    case day1 = 1  // Preparation
    case day2 = 2  // High Intensity
    case day3 = 3  // Active Recovery
    case day4 = 4  // Structural Volume

    var name: String {
        switch self {
        case .day1: return "Preparation"
        case .day2: return "High Intensity"
        case .day3: return "Active Recovery"
        case .day4: return "Structural Volume"
        }
    }

    var description: String {
        switch self {
        case .day1: return "KB Swings, Med Ball, Speed Pull-Ups, Goblet Squats"
        case .day2: return "Weighted Pull-Ups, Deadlifts, Overhead Press, Hanging Leg Raises"
        case .day3: return "Swimming / Mobility"
        case .day4: return "Volume Pull-Ups, Back Squats, Incline Press, Landmine Twists"
        }
    }

    var nextDay: TetradDay {
        switch self {
        case .day1: return .day2
        case .day2: return .day3
        case .day3: return .day4
        case .day4: return .day1
        }
    }
}
