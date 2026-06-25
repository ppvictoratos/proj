import SwiftData
import SwiftUI

/// Convenience queries on top of SwiftData.
extension ModelContext {

    var party: [Rock] {
        let descriptor = FetchDescriptor<Rock>(
            predicate: #Predicate { $0.isInParty },
            sortBy: [SortDescriptor(\.dateFound)]
        )
        return (try? fetch(descriptor)) ?? []
    }

    var storage: [Rock] {
        let descriptor = FetchDescriptor<Rock>(
            predicate: #Predicate { !$0.isInParty },
            sortBy: [SortDescriptor(\.dateFound, order: .reverse)]
        )
        return (try? fetch(descriptor)) ?? []
    }

    /// Move a rock into the active party (max 3).
    func sendToParty(_ rock: Rock) throws {
        guard party.count < 3 else {
            throw RockError.partyFull
        }
        rock.isInParty = true
        try save()
    }

    /// Move a rock back to PC storage.
    func storeInPC(_ rock: Rock) throws {
        rock.isInParty = false
        try save()
    }
}

enum RockError: LocalizedError {
    case partyFull
    var errorDescription: String? {
        switch self {
        case .partyFull: return "Your party is full. Store a rock in the PC first."
        }
    }
}
