import AVFoundation
import Combine

class AudioEngine: NSObject, ObservableObject {
    @Published var currentFile: AudioFileMetadata?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var audioMetrics = AudioMetrics()

    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var playerNode: AVAudioPlayerNode?
    private var displayLink: CADisplayLink?
    private var audioAnalyzer: AudioAnalyzer?
    private var audioBuffer: [Float] = Array(repeating: 0, count: 4096)

    override init() {
        super.init()
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        audioAnalyzer = AudioAnalyzer()

        guard let engine = audioEngine, let player = playerNode else { return }
        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch {
            print("AudioEngine start error: \(error)")
        }
    }

    func loadFile(_ url: URL) {
        guard let engine = audioEngine, let player = playerNode else { return }

        do {
            audioFile = try AVAudioFile(forReading: url)

            guard let file = audioFile else { return }
            let duration = AVAudioFramePosition(file.length) / file.processingFormat.sampleRate

            currentFile = AudioFileMetadata(
                url: url,
                duration: TimeInterval(duration),
                filename: url.lastPathComponent
            )

            if player.isPlaying { player.stop() }

            engine.disconnectNodeInput(player)
            let format = file.processingFormat
            engine.connect(player, to: engine.mainMixerNode, format: format)

            player.scheduleFile(file, at: nil)
        } catch {
            print("Error loading audio file: \(error)")
        }
    }

    func play() {
        guard let player = playerNode, let engine = audioEngine else { return }

        if !player.isPlaying {
            do {
                try engine.start()
                player.play()
                isPlaying = true
                startDisplayLink()
            } catch {
                print("Playback error: \(error)")
            }
        }
    }

    func pause() {
        playerNode?.pause()
        isPlaying = false
        displayLink?.invalidate()
        displayLink = nil
    }

    func seek(to time: TimeInterval) {
        guard let player = playerNode, let file = audioFile else { return }

        let sampleRate = file.processingFormat.sampleRate
        let framePosition = AVAudioFramePosition(time * sampleRate)

        player.stop()
        player.scheduleFile(file, at: AVAudioTime(sampleTime: framePosition, atRate: sampleRate))

        if isPlaying {
            player.play()
        }
    }

    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateMetrics))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateMetrics() {
        guard let player = playerNode, let file = audioFile else { return }

        let sampleRate = file.processingFormat.sampleRate
        let currentSample = player.lastRenderTime?.sampleTime ?? 0
        currentTime = TimeInterval(currentSample) / sampleRate

        var audioBuffer = [Float](repeating: 0, count: 1024)

        if let analyzer = audioAnalyzer {
            audioMetrics = analyzer.analyzeAudioBuffer(audioBuffer, sampleRate: Float(sampleRate))
        }
    }
}
