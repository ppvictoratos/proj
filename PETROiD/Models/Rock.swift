import Foundation
import SwiftData
import CoreLocation

/// A single rock in the player's collection.
@Model
final class Rock {
    var id: UUID
    var name: String           // "Granite"
    var nickname: String       // "Gritstone" — player-set
    var rockType: String       // "granite" — maps to illustration asset
    var hardness: Double       // Mohs scale
    var density: Double        // g/cm³
    var wins: Int
    var losses: Int
    var tag: String            // "IGNEOUS", "VOLCANIC", etc.
    var tagColor: String       // hex string
    var dateFound: Date
    var latitude: Double?      // where it was scanned
    var longitude: Double?
    var isInParty: Bool        // true = one of the active 3
    var photoData: Data?       // optional photo from scan

    // Battle stats (0–10)
    var statHardness: Int
    var statDensity: Int
    var statRarity: Int
    var statBattle: Int

    init(
        name: String,
        nickname: String,
        rockType: String,
        hardness: Double,
        density: Double,
        tag: String,
        tagColor: String,
        statHardness: Int,
        statDensity: Int,
        statRarity: Int,
        statBattle: Int,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.nickname = nickname
        self.rockType = rockType
        self.hardness = hardness
        self.density = density
        self.wins = 0
        self.losses = 0
        self.tag = tag
        self.tagColor = tagColor
        self.dateFound = Date()
        self.latitude = latitude
        self.longitude = longitude
        self.isInParty = false
        self.statHardness = statHardness
        self.statDensity = statDensity
        self.statRarity = statRarity
        self.statBattle = statBattle
    }
}
