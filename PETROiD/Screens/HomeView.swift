import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Rock> { $0.isInParty }) private var party: [Rock]
    @Query(sort: \.dateFound, order: .reverse) private var allRocks: [Rock]

    @State private var isScanning = false
    @State private var scannedRock: Rock?
    @State private var selectedRock: Rock?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PartySlotRow(party: party, onSelect: { selectedRock = $0 })
                    ScanButton(isScanning: $isScanning, onComplete: { rock in
                        scannedRock = rock
                    })
                    RockList(rocks: allRocks, onSelect: { selectedRock = $0 })
                }
                .padding()
            }
            .navigationTitle("PETROiD")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $scannedRock) { rock in
                ScanResultView(rock: rock)
            }
            .navigationDestination(item: $selectedRock) { rock in
                DetailView(rock: rock)
            }
        }
        .background(Color("Background"))
    }
}

// ── Party row ──────────────────────────────────────────────
struct PartySlotRow: View {
    let party: [Rock]
    let onSelect: (Rock) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                if i < party.count {
                    PartySlot(rock: party[i])
                        .onTapGesture { onSelect(party[i]) }
                } else {
                    EmptySlot()
                }
            }
        }
    }
}

struct PartySlot: View {
    let rock: Rock
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Surface"))
                .frame(height: 80)
                .overlay(
                    // TODO: replace with RockIllustrationView(type: rock.rockType)
                    Image(systemName: "mountain.2.fill")
                        .foregroundStyle(Color("AccentGreen"))
                )
            Text(rock.name)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color("TextMuted"))
        }
    }
}

struct EmptySlot: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(Color("TextFaint").opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
            .frame(height: 80)
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "plus")
                        .foregroundStyle(Color("TextFaint"))
                    Text("Empty")
                        .font(.system(size: 9))
                        .foregroundStyle(Color("TextFaint"))
                }
            )
    }
}

struct RockList: View {
    let rocks: [Rock]
    let onSelect: (Rock) -> Void
    var body: some View {
        ForEach(rocks) { rock in
            RockRowCard(rock: rock)
                .onTapGesture { onSelect(rock) }
        }
    }
}
