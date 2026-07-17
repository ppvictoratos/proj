import Foundation

enum Program: String, Codable, Hashable, CaseIterable {
    case injury = "Injury Recovery"
    case tetrad = "Tetrad Athletic"

    var displayName: String {
        self.rawValue
    }

    var description: String {
        switch self {
        case .injury:
            return "Spine recovery & mobility focus. Daily resets and approved movements."
        case .tetrad:
            return "4-day power/strength/volume cycle with heavy focus."
        }
    }
}
