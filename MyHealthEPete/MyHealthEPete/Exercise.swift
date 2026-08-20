import CoreData

@objc(Exercise)
public class Exercise: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var type: String
    @NSManaged public var weight: Double
    @NSManaged public var duration: Int32
    @NSManaged public var notes: String?

    var formattedWeight: String {
        weight > 0 ? String(format: "%.1fkg", weight) : "--"
    }

    var formattedDuration: String {
        duration > 0 ? "\(duration)min" : "--"
    }
}
