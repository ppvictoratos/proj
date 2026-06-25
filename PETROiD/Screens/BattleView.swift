import SwiftUI
import SwiftData

struct BattleView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Rock> { $0.isInParty }) private var party: [Rock]
    @StateObject private var nfc = NFCService()

    @State private var myRock: Rock?
    @State private var phase: BattlePhase = .idle

    enum BattlePhase { case idle, scanning, found, selecting, countdown(Int), fighting, result(Bool) }

    var body: some View {
        NavigationStack {
            VStack {
                switch phase {
                case .idle:
                    IdleView { phase = .scanning; nfc.startScan() }
                case .scanning:
                    NFCScanningView()
                case .found:
                    TrainerFoundView { phase = .selecting }
                case .selecting:
                    RockSelectView(party: party, selected: $myRock) {
                        startCountdown()
                    }
                case .countdown(let n):
                    CountdownView(n: n)
                case .fighting:
                    FightingView()
                case .result(let won):
                    ResultView(won: won, rock: myRock) {
                        phase = .idle
                    }
                }
            }
            .navigationTitle("Battle")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("Background"))
        }
        .onChange(of: nfc.trainerFound) { _, found in
            if found { phase = .found }
        }
    }

    private func startCountdown() {
        Task { @MainActor in
            for n in stride(from: 3, through: 1, by: -1) {
                phase = .countdown(n)
                try? await Task.sleep(for: .seconds(0.8))
            }
            phase = .fighting
            try? await Task.sleep(for: .seconds(1.4))
            let won = (myRock?.statBattle ?? 0) >= 7 // placeholder — real logic uses opponent rock from NFC
            if won { myRock?.wins += 1 } else { myRock?.losses += 1 }
            try? context.save()
            phase = .result(won)
        }
    }
}

// Placeholder sub-views — fill in with real UI matching the prototype
struct IdleView: View {
    let onTap: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wave.3.right")
                .font(.system(size: 48))
                .foregroundStyle(Color("AccentGreen"))
            Text("Hold near another trainer\nto start a battle")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("TextMuted"))
            Button("Scan for Trainer", action: onTap)
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentGreen"))
        }
        .padding()
    }
}

struct NFCScanningView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView().tint(Color("AccentGreen"))
            Text("Scanning for nearby trainer…")
                .foregroundStyle(Color("TextMuted"))
        }
    }
}

struct TrainerFoundView: View {
    let onContinue: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.wave.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color("AccentGreen"))
            Text("Trainer detected!")
                .font(.title2.bold())
            Button("Choose Your Rock", action: onContinue)
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentGreen"))
        }
    }
}

struct RockSelectView: View {
    let party: [Rock]
    @Binding var selected: Rock?
    let onBattle: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose your fighter")
                .font(.headline)
                .padding(.horizontal)
            ForEach(party) { rock in
                HStack {
                    Text(rock.name).font(.system(.body, design: .monospaced))
                    Spacer()
                    if selected?.id == rock.id {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color("AccentGreen"))
                    }
                }
                .padding()
                .background(selected?.id == rock.id ? Color("AccentGreen").opacity(0.12) : Color("Surface"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .onTapGesture { selected = rock }
            }
            Button("⚔ Start Battle") { onBattle() }
                .disabled(selected == nil)
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentGreen"))
                .padding()
        }
    }
}

struct CountdownView: View {
    let n: Int
    var body: some View {
        Text(n == 0 ? "GO!" : "\(n)")
            .font(.system(size: 80, weight: .black, design: .monospaced))
            .foregroundStyle(Color("AccentGreen"))
    }
}

struct FightingView: View {
    var body: some View {
        Text("⚡ BATTLING ⚡")
            .font(.system(size: 22, weight: .black))
            .foregroundStyle(Color("TextPrimary"))
    }
}

struct ResultView: View {
    let won: Bool; let rock: Rock?; let onDone: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Text(won ? "Victory!" : "Defeated")
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(won ? Color("AccentGreen") : Color("TextMuted"))
            if let rock { Text(rock.name).foregroundStyle(Color("TextMuted")) }
            Button("Back to Home", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentGreen"))
        }
    }
}
