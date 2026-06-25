import Vision
import UIKit

/// Rock classification using Vision.
/// Currently uses the built-in image classifier as a placeholder.
/// REPLACE with a custom CoreML model trained on labeled rock photos
/// for real hardness/type prediction.
///
/// Training pipeline (future):
///   1. Collect ~500+ photos per rock type with Mohs labels
///   2. Train with Create ML (Image Classifier template)
///   3. Export as .mlpackage → drag into Xcode
///   4. Replace VNClassifyImageRequest below with VNCoreMLRequest(model:)
enum VisionService {

    struct ClassificationResult {
        let rockType: String   // e.g. "granite"
        let confidence: Float
        let estimatedHardness: Double? // nil until custom model
    }

    static func classify(image: UIImage) async -> ClassificationResult? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, _ in
                guard let results = request.results as? [VNClassificationObservation],
                      let top = results.first(where: { $0.confidence > 0.2 }) else {
                    continuation.resume(returning: nil)
                    return
                }
                // Map Vision labels to rock names (best-effort with stock model)
                let mapped = mapToRockType(top.identifier)
                continuation.resume(returning: ClassificationResult(
                    rockType: mapped,
                    confidence: top.confidence,
                    estimatedHardness: hardnessEstimate(for: mapped)
                ))
            }
            try? VNImageRequestHandler(cgImage: cgImage).perform([request])
        }
    }

    // ── Label mapping ──────────────────────────────────────
    private static func mapToRockType(_ label: String) -> String {
        let l = label.lowercased()
        if l.contains("sand") || l.contains("sediment")   { return "sandstone" }
        if l.contains("crystal") || l.contains("quartz")  { return "quartz" }
        if l.contains("dark") || l.contains("black")      { return "obsidian" }
        if l.contains("gray") || l.contains("granite")    { return "granite" }
        if l.contains("white") || l.contains("marble")    { return "marble" }
        return "granite" // default fallback
    }

    private static func hardnessEstimate(for type: String) -> Double? {
        // Stock model can't reliably estimate hardness — return nil
        // Custom model would regress this from texture features
        return nil
    }
}
