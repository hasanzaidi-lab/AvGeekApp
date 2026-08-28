import Foundation

enum APIConfiguration {
    static var rapidAPIKey: String {
        if let env = ProcessInfo.processInfo.environment["RAPIDAPI_KEY"], !env.isEmpty {
            return env
        }

        if let bundled = Bundle.main.object(forInfoDictionaryKey: "RapidAPIKey") as? String,
           isUsable(bundled) {
            return bundled
        }

        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let key = plist["RAPIDAPI_KEY"] as? String,
           isUsable(key) {
            return key
        }

        return ""
    }

    private static func isUsable(_ key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty
            && trimmed != "YOUR_RAPIDAPI_KEY"
            && !trimmed.hasPrefix("$(")
    }
}
