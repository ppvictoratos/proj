import SwiftUI
import SwiftData

/// macOS-only storage browser (Mac Catalyst or native macOS target).
struct RockPCView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Rock> { !$0.isInParty }, sort: \.dateFound, order: .reverse) private var storage: [Rock]
    @Query(filter: #Predicate<Rock> { $0.isInParty }) private var party: [Rock]
    @State private var selected: Rock?
    @State private var search = ""

    var filtered: [Rock] {
        guard !search.isEmpty else { return storage }
        return storage.filter { $0.name.localizedCaseInsensitiveContains(search) || $0.nickname.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selected) {
                Section("Storage Box (\(storage.count))") {
                    ForEach(filtered) { rock in
                        RockSidebarRow(rock: rock)
                            .tag(rock)
                    }
                }
                Section("Active Party (\(party.count)/3)") {
                    ForEach(party) { rock in
                        RockSidebarRow(rock: rock)
                            .tag(rock)
                    }
                }
            }
            .searchable(text: $search)
            .navigationTitle("Rock PC")
        } detail: {
            if let rock = selected {
                RockPCDetailView(rock: rock, isInParty: party.contains(where: { $0.id == rock.id }), partyFull: party.count >= 3) {
                    try? context.sendToParty(rock)
                } onStore: {
                    try? context.storeInPC(rock)
                }
            } else {
                Text("Select a rock")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct RockSidebarRow: View {
    let rock: Rock
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "mountain.2.fill")
                .foregroundStyle(Color("AccentGreen"))
            VStack(alignment: .leading, spacing: 1) {
                Text(rock.name).font(.system(size: 13, weight: .semibold))
                Text(rock.nickname).font(.system(size: 11)).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(rock.wins)W").font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color("AccentGreen"))
        }
    }
}

struct RockPCDetailView: View {
    let rock: Rock
    let isInParty: Bool
    let partyFull: Bool
    let onSendToParty: () -> Void
    let onStore: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                RockHeroView(rockType: rock.rockType)
                Text(rock.name).font(.system(size: 28, weight: .bold))
                StatsCard(rock: rock)
                PropertiesCard(rock: rock)

                if isInParty {
                    Button("← Store in PC", action: onStore)
                        .buttonStyle(.bordered)
                } else {
                    Button(partyFull ? "Party Full (3/3)" : "Send to Party →", action: onSendToParty)
                        .disabled(partyFull)
                        .buttonStyle(.borderedProminent)
                        .tint(Color("AccentGreen"))
                }
            }
            .padding(24)
        }
    }
}
