import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        let model = Self.createModel()
        container = NSPersistentContainer(name: "MyHealthEPete", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "Exercise"
        entity.managedObjectClassName = "Exercise"

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let date = NSAttributeDescription()
        date.name = "date"
        date.attributeType = .dateAttributeType
        date.isOptional = false

        let type = NSAttributeDescription()
        type.name = "type"
        type.attributeType = .stringAttributeType
        type.isOptional = false

        let weight = NSAttributeDescription()
        weight.name = "weight"
        weight.attributeType = .doubleAttributeType
        weight.isOptional = true

        let duration = NSAttributeDescription()
        duration.name = "duration"
        duration.attributeType = .integer32AttributeType
        duration.isOptional = true

        let notes = NSAttributeDescription()
        notes.name = "notes"
        notes.attributeType = .stringAttributeType
        notes.isOptional = true

        entity.properties = [id, date, type, weight, duration, notes]
        model.entities = [entity]

        return model
    }
}
