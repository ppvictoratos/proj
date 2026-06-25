import Foundation
import CoreNFC
import Combine

/// Wraps CoreNFC NDEF reading/writing for the battle handshake.
/// One device writes a challenge; the other reads and accepts.
@MainActor
final class NFCService: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {

    @Published var trainerFound = false
    @Published var challengeRockID: UUID?
    @Published var error: String?

    private var session: NFCNDEFReaderSession?

    // ── Start scanning ─────────────────────────────────────
    func startScan() {
        guard NFCNDEFReaderSession.readingAvailable else {
            error = "NFC not available on this device"
            return
        }
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: .main,
            invalidateAfterFirstRead: false
        )
        session?.alertMessage = "Hold your iPhone near another PETROiD player"
        session?.begin()
    }

    // ── Write a challenge (challenger side) ────────────────
    func writeChallenge(rockID: UUID, to tag: NFCNDEFTag) async throws {
        let payload = NFCNDEFPayload(
            format: .unknown,
            type: "petroid/challenge".data(using: .utf8)!,
            identifier: Data(),
            payload: rockID.uuidString.data(using: .utf8)!
        )
        let message = NFCNDEFMessage(records: [payload])
        try await tag.writeNDEF(message)
    }

    // ── Delegate ───────────────────────────────────────────
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in self.error = error.localizedDescription }
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first,
              String(data: record.type, encoding: .utf8) == "petroid/challenge",
              let idString = String(data: record.payload, encoding: .utf8),
              let uuid = UUID(uuidString: idString) else { return }

        Task { @MainActor in
            self.challengeRockID = uuid
            self.trainerFound = true
        }
    }
}
