import Foundation

struct WikiSummary {
    let extract: String
    let pageURL: URL?
}

enum WikiService {
    static func fetch(for rockName: String) async -> WikiSummary? {
        guard let encoded = rockName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)") else { return nil }

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let extract = json["extract"] as? String else { return nil }

        let sentences = extract.components(separatedBy: ". ")
        let snippet = sentences.prefix(2).joined(separator: ". ") + "."

        let pageURL: URL? = {
            if let desktop = ((json["content_urls"] as? [String: Any])?["desktop"] as? [String: Any])?["page"] as? String {
                return URL(string: desktop)
            }
            return nil
        }()

        return WikiSummary(extract: snippet, pageURL: pageURL)
    }
}
