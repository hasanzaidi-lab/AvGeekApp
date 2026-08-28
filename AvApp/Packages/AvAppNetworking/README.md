# AvAppNetworking

Shared Swift package for AeroDataBox (RapidAPI) and OpenSky requests.

## Setup
Pass the RapidAPI key into `FlightService` and `AircraftService`. Do not hardcode secrets in this package.

```swift
let client = URLSessionNetworkClient()
let flights = FlightService(client: client, apiKey: apiKey)
let aircraft = AircraftService(client: client, apiKey: apiKey)
let tracks = TrackService(client: client)
```

## Testing
`MockNetworkClient` and `MockFlightService` / `MockAircraftService` / `MockTrackService` are available for unit tests and SwiftUI previews.

```bash
swift test --package-path AvApp/Packages/AvAppNetworking
```
