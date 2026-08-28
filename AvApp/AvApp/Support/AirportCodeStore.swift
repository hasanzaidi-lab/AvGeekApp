import Foundation

protocol AirportCodeStoring: Sendable {
    func load(default defaultCode: String) -> String
    func save(_ code: String)
}

struct UserDefaultsAirportStore: AirportCodeStoring, @unchecked Sendable {
    static let storageKey = "lastAirportCode"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(default defaultCode: String) -> String {
        let stored = defaults.string(forKey: Self.storageKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let stored, !stored.isEmpty {
            return stored.uppercased()
        }
        return defaultCode
    }

    func save(_ code: String) {
        defaults.set(code, forKey: Self.storageKey)
    }
}
