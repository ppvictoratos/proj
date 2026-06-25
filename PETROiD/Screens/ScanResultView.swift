import SwiftUI

struct ScanResultView: View {
    let rock: Rock
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Rock> { $0.isInParty }) private var party: [Rock]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    RockHeroView(rockType: rock.rockType)

                    Text(rock.name)
                        .font(.system(size: 26, weight: .bold))

                    StatsCard(rock: rock)

                    HStack(spacing: 12) {
                        Button("Release") {
                            context.delete(rock)
                            try? context.save()
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("TextMuted"))

                        Button(party.count >= 3 ? "Party Full" : "Add to Party") {
                            try? context.sendToParty(rock)
                            dismiss()
                        }
                        .disabled(party.count >= 3)
                        .buttonStyle(.borderedProminent)
                        .tint(Color("AccentGreen"))
                    }

                    if party.count >= 3 {
                        Text("Open Rock PC on your Mac to free up a slot")
                            .font(.system(size: 11))
                            .foregroundStyle(Color("TextFaint"))
                    }
                }
                .padding()
            }
            .navigationTitle("New Rock Found!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
