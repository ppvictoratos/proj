import Accelerate
import AVFoundation

class AudioAnalyzer {
    private let fftSetup: vDSP_DFT_Setup
    private let fftSize = 2048
    private var realBuffer: [Float]
    private var imagBuffer: [Float]
    private var frequencyBands: [Float] = Array(repeating: 0, count: 32)
    private let bandCount = 32

    private var energyHistory: [Float] = []
    private let energyHistorySize = 10
    private var lastBeatTime: TimeInterval = 0
    private let beatThreshold: Float = 0.6

    init() {
        guard let setup = vDSP_DFT_zop_CreateSetup(vDSP_Length(fftSize), vDSP_DFT_Direction.FORWARD)
        else {
            fatalError("Failed to create FFT setup")
        }
        fftSetup = setup

        realBuffer = Array(repeating: 0, count: fftSize)
        imagBuffer = Array(repeating: 0, count: fftSize)
    }

    deinit {
        vDSP_DFT_DestroySetup(fftSetup)
    }

    func analyzeAudioBuffer(_ buffer: [Float], sampleRate: Float) -> AudioMetrics {
        let timestamp = ProcessInfo.processInfo.systemUptime

        computeFFT(buffer)
        extractFrequencyBands(sampleRate: sampleRate)

        var sumSquares: Float = 0
        vDSP_svesq(buffer, 1, &sumSquares, vDSP_Length(buffer.count))
        let rms = sqrt(sumSquares / Float(buffer.count))

        let beat = detectBeat(energy: rms, timestamp: timestamp)

        return AudioMetrics(
            frequencies: frequencyBands,
            beat: beat,
            energy: min(rms, 1.0),
            timestamp: timestamp
        )
    }

    private func computeFFT(_ input: [Float]) {
        realBuffer = input
        imagBuffer = Array(repeating: 0, count: fftSize)

        vDSP_DFT_Execute(fftSetup, &realBuffer, &imagBuffer, vDSP_DFT_Direction.FORWARD)
    }

    private func extractFrequencyBands(sampleRate: Float) {
        var magnitudes = [Float](repeating: 0, count: fftSize / 2)

        for i in 0..<fftSize / 2 {
            let real = realBuffer[i]
            let imag = imagBuffer[i]
            let magnitude = sqrt(real * real + imag * imag)
            magnitudes[i] = magnitude
        }

        for band in 0..<bandCount {
            let bandStart = pow(2.0, Float(band) / Float(bandCount) * log2(Float(fftSize / 2)))
            let bandEnd = pow(2.0, Float(band + 1) / Float(bandCount) * log2(Float(fftSize / 2)))

            let startIdx = Int(bandStart)
            let endIdx = min(Int(bandEnd), fftSize / 2 - 1)

            var bandMax: Float = 0
            for i in startIdx...endIdx {
                bandMax = max(bandMax, magnitudes[i])
            }

            frequencyBands[band] = min(bandMax / 1000, 1.0)
        }
    }

    private func detectBeat(energy: Float, timestamp: TimeInterval) -> Bool {
        energyHistory.append(energy)
        if energyHistory.count > energyHistorySize {
            energyHistory.removeFirst()
        }

        let avgEnergy = energyHistory.dropLast().reduce(0, +) / Float(max(energyHistory.count - 1, 1))
        let isTransient = energy > avgEnergy * 1.5 && energy > beatThreshold

        if isTransient && (timestamp - lastBeatTime > 0.1) {
            lastBeatTime = timestamp
            return true
        }
        return false
    }
}
