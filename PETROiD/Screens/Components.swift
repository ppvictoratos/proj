import SwiftUI
import PhotosUI
import Vision

// ── ScanButton ────────────────────────────────────────────────────────────────
struct ScanButton: View {
    @Binding var isScanning: Bool
    let onComplete: (Rock) -> Void

    @Environment(\.modelContext) private var context
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            HStack(spacing: 10) {
                Image(systemName: isScanning ? "viewfinder.circle.fill" : "viewfinder")
                    .font(.system(size: 18, weight: .semibold))
                Text(isScanning ? "Identifying…" : "Scan a Rock")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
            }
            .foregroundStyle(Color("Background"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isScanning ? Color("AccentGreen").opacity(0.6) : Color("AccentGreen"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isScanning)
        .onChange(of: selectedPhoto) { _, item in
            Task { await classify(item: item) }
        }
    }

    @MainActor
    private func classify(item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }

        isScanning = true
        defer { isScanning = false }

        let result = await VisionService.classify(image: uiImage)
        let rockType = result?.rockType ?? "granite"
        let rock = makeRock(type: rockType, photoData: data)
        context.insert(rock)
        try? context.save()
        onComplete(rock)
        selectedPhoto = nil
    }

    private func makeRock(type: String, photoData: Data) -> Rock {
        let catalog: [String: (name: String, tag: String, tagColor: String, hardness: Double, density: Double, h: Int, d: Int, r: Int, b: Int)] = [
            "granite":   ("Granite",   "IGNEOUS",     "#6B7280", 6.5, 2.7, 7, 6, 5, 6),
            "obsidian":  ("Obsidian",  "VOLCANIC",    "#374151", 5.5, 2.4, 6, 5, 8, 7),
            "quartz":    ("Quartz",    "MINERAL",     "#D1FAE5", 7.0, 2.6, 8, 5, 6, 7),
            "sandstone": ("Sandstone", "SEDIMENTARY", "#92400E", 3.0, 2.2, 3, 4, 3, 3),
            "marble":    ("Marble",    "METAMORPHIC", "#E5E7EB", 3.5, 2.7, 4, 6, 4, 4),
            "basalt":    ("Basalt",    "VOLCANIC",    "#1F2937", 6.0, 3.0, 6, 8, 5, 7),
            "limestone": ("Limestone", "SEDIMENTARY", "#D97706", 3.5, 2.5, 4, 5, 3, 3),
            "schist":    ("Schist",    "METAMORPHIC", "#6EE7B7", 4.0, 2.8, 4, 6, 4, 4),
        ]
        let entry = catalog[type] ?? catalog["granite"]!
        let rock = Rock(
            name: entry.name,
            nickname: randomNickname(),
            rockType: type,
            hardness: entry.hardness,
            density: entry.density,
            tag: entry.tag,
            tagColor: entry.tagColor,
            statHardness: entry.h,
            statDensity: entry.d,
            statRarity: entry.r,
            statBattle: entry.b
        )
        rock.photoData = photoData
        return rock
    }

    private func randomNickname() -> String {
        let names = ["Pebbles", "Boulder", "Chip", "Grit", "Slate", "Flint", "Rocky", "Cobble", "Crag", "Shale"]
        return names.randomElement()!
    }
}

// ── RockRowCard ───────────────────────────────────────────────────────────────
struct RockRowCard: View {
    let rock: Rock

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("Surface"))
                    .frame(width: 52, height: 52)
                if let data = rock.photoData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "mountain.2.fill")
                        .foregroundStyle(Color("AccentGreen").opacity(0.7))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(rock.name)
                    .font(.system(size: 14, weight: .semibold))
                Text("\"\(rock.nickname)\"")
                    .font(.system(size: 11))
                    .foregroundStyle(Color("TextMuted"))
                Text(rock.tag)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color("AccentGreen"))
                    .kerning(0.8)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("BP \(rock.statBattle)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color("AccentGreen"))
                HStack(spacing: 4) {
                    Text("\(rock.wins)W")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color("AccentGreen"))
                    Text("\(rock.losses)L")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color("TextMuted"))
                }
                if rock.isInParty {
                    Text("PARTY")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(Color("Background"))
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(Color("AccentGreen"))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(12)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
