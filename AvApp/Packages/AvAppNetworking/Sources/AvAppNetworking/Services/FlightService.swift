import Foundation

public final class FlightService: FlightFetching, Sendable {
    private let client: NetworkClient
    private let apiKey: String
    private let host: String
    private let baseURL = "https://aerodatabox.p.rapidapi.com/flights/airports/iata/"

    public init(
        client: NetworkClient = URLSessionNetworkClient(),
        apiKey: String,
        host: String = "aerodatabox.p.rapidapi.com"
    ) {
        self.client = client
        self.apiKey = apiKey
        self.host = host
    }

    public func fetchFlights(for airportCode: String) async throws -> FlightResponse {
        guard !apiKey.isEmpty else {
            throw NetworkError.missingAPIKey
        }

        let sanitized = airportCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let query = "?offsetMinutes=-120&durationMinutes=720&withLeg=true&direction=Both&withCancelled=true&withCodeshared=true&withCargo=true&withPrivate=true&withLocation=false"
        let urlString = "\(baseURL)\(sanitized)\(query)"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL(urlString)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(host, forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")

        return try await client.request(request)
    }
}
