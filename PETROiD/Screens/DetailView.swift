import SwiftUI
import MapKit

struct DetailView: View {
    let rock: Rock
    @Environment(\.modelContext) private var context
    @State private var wikiFactoid: String?
    @State private var wikiURL: URL?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Rock illustration
                RockHeroView(rockType: rock.rockType)

                // Name + nickname
                VStack(spacing: 4) {
                    Text(rock.name)
                        .font(.system(size: 26, weight: .bold, design: .default))
                    Text("\"\(rock.nickname)\"")
                        .font(.system(size: 13))
                        .foregroundStyle(Color("TextMuted"))
                }

                // Win/loss pills
                HStack(spacing: 10) {
                    StatPill(value: "\(rock.wins)W", color: Color("AccentGreen"))
                    StatPill(value: "\(rock.losses)L", color: Color("TextMuted"))
                }

                // Battle stats
                StatsCard(rock: rock)

                // Properties
                PropertiesCard(rock: rock)

                // Wikipedia factoid
                if let factoid = wikiFactoid {
                    FactoidCard(text: factoid, url: wikiURL)
                }

                // Map pin — ultra light, only if location known
                if let lat = rock.latitude, let lon = rock.longitude {
                    MapPinView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                }
            }
            .padding()
        }
        .navigationTitle(rock.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("Background"))
        .task { await fetchWiki() }
    }

    private func fetchWiki() async {
        guard let summary = await WikiService.fetch(for: rock.name) else { return }
        wikiFactoid = summary.extract
        wikiURL = summary.pageURL
    }
}

struct MapPinView: View {
    let coordinate: CLLocationCoordinate2D
    var body: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))) {
            Marker("", coordinate: coordinate)
                .tint(Color("AccentGreen").opacity(0.3))
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .disabled(true) // view-only
        .opacity(0.7)   // super subtle
    }
}

struct RockHeroView: View {
    let rockType: String
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("AccentGreen").opacity(0.06))
                .frame(width: 160, height: 160)
            // TODO: swap for actual RockIllustrationView
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color("AccentGreen").opacity(0.8))
        }
    }
}

struct StatsCard: View {
    let rock: Rock
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BATTLE STATS")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color("TextFaint"))
                .kerning(1.5)
            StatRow(label: "Hardness",    value: rock.statHardness,  color: Color("AccentGreen"))
            StatRow(label: "Density",     value: rock.statDensity,   color: Color("AccentGreen"))
            StatRow(label: "Rarity",      value: rock.statRarity,    color: Color("Mint"))
            StatRow(label: "Battle Power",value: rock.statBattle,    color: Color.yellow)
        }
        .padding(16)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StatRow: View {
    let label: String; let value: Int; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label).font(.system(size: 11)).foregroundStyle(Color("TextMuted"))
                Spacer()
                Text("\(value)/10").font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.06))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color.gradient)
                            .frame(width: geo.size.width * CGFloat(value) / 10)
                    }
            }
            .frame(height: 4)
        }
    }
}

struct PropertiesCard: View {
    let rock: Rock
    var body: some View {
        VStack(spacing: 0) {
            row("Hardness", "\(rock.hardness) Mohs")
            Divider().background(Color("TextFaint").opacity(0.2))
            row("Density",  "\(rock.density) g/cm³")
            Divider().background(Color("TextFaint").opacity(0.2))
            row("Type",     rock.tag)
        }
        .padding(16)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    func row(_ k: String, _ v: String) -> some View {
        HStack {
            Text(k).font(.system(size: 12)).foregroundStyle(Color("TextMuted"))
            Spacer()
            Text(v).font(.system(size: 12, weight: .semibold, design: .monospaced))
        }
        .padding(.vertical, 8)
    }
}

struct FactoidCard: View {
    let text: String; let url: URL?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("✦ FROM WIKIPEDIA")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color("AccentGreen"))
                .kerning(1.2)
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(Color("TextMuted"))
                .lineSpacing(4)
            if let url {
                Link("Read more →", destination: url)
                    .font(.system(size: 11))
                    .foregroundStyle(Color("AccentGreen"))
            }
        }
        .padding(14)
        .background(Color("AccentGreen").opacity(0.06))
        .overlay(alignment: .leading) {
            Rectangle().fill(Color("AccentGreen").opacity(0.4)).frame(width: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatPill: View {
    let value: String; let color: Color
    var body: some View {
        Text(value)
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 14).padding(.vertical, 5)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}
