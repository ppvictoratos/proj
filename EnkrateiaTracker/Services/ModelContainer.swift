import SwiftData

final class ModelContainerProvider {
    static let shared = ModelContainerProvider()

    let container: ModelContainer

    private init() {
        let schema = Schema([TetradCycle.self, WorkoutSession.self, ExerciseLog.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not initialize SwiftData: \(error)")
        }
    }
}

extension ModelContext {
    static var preview: ModelContext {
        let container = try! ModelContainer(for: TetradCycle.self,
                                           configurations: .init(isStoredInMemoryOnly: true))
        return ModelContext(container)
    }
}
