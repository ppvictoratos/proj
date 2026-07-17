import Foundation

@MainActor
final class ProgramSelectionViewModel: ObservableObject {
    @Published var selectedProgram: Program {
        didSet {
            UserDefaults.standard.set(selectedProgram.rawValue, forKey: "selectedProgram")
        }
    }

    init() {
        let savedProgram = UserDefaults.standard.string(forKey: "selectedProgram")
        let program = savedProgram.flatMap(Program.init(rawValue:)) ?? .tetrad
        self.selectedProgram = program
    }

    var availablePrograms: [Program] {
        Program.allCases
    }

    func switchProgram(to program: Program) {
        selectedProgram = program
    }
}
