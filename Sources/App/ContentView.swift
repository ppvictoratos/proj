import SwiftUI

struct ContentView: View {
    @StateObject private var audioEngine = AudioEngine()
    @State private var currentProgram: VisualizationProgram = .beatDriven
    @State private var showFileDialog = false

    var body: some View {
        ZStack {
            Group {
                switch currentProgram {
                case .beatDriven:
                    BeatDrivenView(audioMetrics: audioEngine.audioMetrics)
                case .frequencyBand:
                    FrequencyBandView(audioMetrics: audioEngine.audioMetrics)
                case .hybrid:
                    HybridView(audioMetrics: audioEngine.audioMetrics)
                }
            }

            VStack {
                Spacer()

                if audioEngine.currentFile == nil {
                    VStack(spacing: 20) {
                        Text("Drop an MP3 here")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(ColorPalette.primaryGlow)

                        Text("or press ⌘O to open")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(ColorPalette.primaryGlow.opacity(0.6))

                        Button("Browse Files") {
                            showFileDialog = true
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(ColorPalette.primaryGlow.opacity(0.2))
                        .foregroundColor(ColorPalette.primaryGlow)
                        .cornerRadius(6)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                } else {
                    PlaybackControls(audioEngine: audioEngine, currentProgram: currentProgram)
                }
            }
            .fileImporter(
                isPresented: $showFileDialog,
                allowedContentTypes: [.audio],
                onCompletion: { result in
                    if case .success(let url) = result {
                        audioEngine.loadFile(url)
                    }
                }
            )
        }
        .background(ColorPalette.darkBackground)
        .onAppear {
            setupKeyboardMonitoring()
        }
    }

    private func setupKeyboardMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event -> NSEvent? in
            handleKeyEvent(event)
            return event
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        guard let characters = event.characters else { return }

        let char = characters.lowercased().first

        switch char {
        case "p":
            currentProgram.next()
        case "o":
            if event.modifierFlags.contains(.command) {
                showFileDialog = true
            }
        case " ":
            if audioEngine.currentFile != nil {
                audioEngine.isPlaying ? audioEngine.pause() : audioEngine.play()
            }
        default:
            break
        }

        if event.keyCode == 123 {
            if audioEngine.currentFile != nil {
                audioEngine.seek(to: max(0, audioEngine.currentTime - 5))
            }
        } else if event.keyCode == 124 {
            if audioEngine.currentFile != nil {
                audioEngine.seek(to: min(audioEngine.currentFile?.duration ?? 0, audioEngine.currentTime + 5))
            }
        }
    }
}

struct PlaybackControls: View {
    @ObservedObject var audioEngine: AudioEngine
    let currentProgram: VisualizationProgram

    var body: some View {
        VStack(spacing: 16) {
            if let file = audioEngine.currentFile {
                VStack(alignment: .leading, spacing: 4) {
                    Text(file.filename)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ColorPalette.primaryGlow)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(formatTime(audioEngine.currentTime))
                            .font(.system(size: 12, weight: .light, design: .monospaced))

                        Slider(value: $audioEngine.currentTime, in: 0...file.duration)
                            .tint(ColorPalette.primaryGlow)

                        Text(formatTime(file.duration))
                            .font(.system(size: 12, weight: .light, design: .monospaced))
                    }
                    .foregroundColor(ColorPalette.primaryGlow.opacity(0.7))
                }
                .padding(.horizontal, 16)
            }

            HStack(spacing: 16) {
                Button(action: { audioEngine.isPlaying ? audioEngine.pause() : audioEngine.play() }) {
                    Image(systemName: audioEngine.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ColorPalette.primaryGlow)
                }

                Spacer()

                Text(currentProgram.name)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(ColorPalette.primaryGlow.opacity(0.5))
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(ColorPalette.darkBackground.opacity(0.9))
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

#Preview {
    ContentView()
}
