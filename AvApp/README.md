# AvApp

AvApp is a SwiftUI-based flight tracker that surfaces airport departures/arrivals and per-aircraft details backed by the AeroDataBox RapidAPI. The UI is intentionally simple so that new features (like MapKit overlays) can be layered on top of a clean, testable networking core.

## Tech stack
- SwiftUI + NavigationStack + TabView for UI structure
- MapKit for the upcoming airport radar/map integration
- Swift Concurrency (`async`/`await`) for flight fetching and background updates
- Swift Package Manager for the reusable networking layer (`Packages/AvAppNetworking`)
- XCTest targets (`AvAppTests`, `AvAppUITests`, `Packages/AvAppNetworking/Tests`)

## Directory layout
```
AvApp/
├── AvApp/                      # App target sources (SwiftUI views, view models, Assets)
│   └── Features/
│       ├── MVP/                # Shipping flight list experience
│       └── MapKitInteg/        # Experimental map-centric prototype
├── AvAppTests/                 # Unit tests for the app target
├── AvAppUITests/               # UI / snapshot tests
├── Packages/
│   └── AvAppNetworking/        # Swift package consumed by the app
│       ├── Sources/AvAppNetworking/
│       │   ├── Client/         # NetworkClient + NetworkError
│       │   ├── Models/         # Flight + aircraft DTOs
│       │   ├── Services/       # FlightService + AircraftService
│       │   └── Support/        # FlightMocks for previews/tests
│       └── Tests/              # Package-level unit tests
└── README.md
```

### Module overview
| Module | Responsibility | Notes |
| --- | --- | --- |
| `AvApp` | User interface, app lifecycle, feature composition | Depends on `AvAppNetworking` for data and exposes feature folders (`Features/MVP`, `Features/MapKitInteg`). |
| `AvAppNetworking` | Fetches flight/aircraft data from RapidAPI with strong typing and detailed errors. | Distributed as a Swift package inside `Packages/`; shared clients can re-use it. |
| `AvAppTests` / `AvAppUITests` | Regression and UI coverage. | Adopt the same folder naming as the app target so files are easy to locate. |

## Getting started
1. **Install tools** – Xcode 16.0+ (Swift 6 toolchain). The package manifest targets iOS 15+, macOS 12+, tvOS 15+, watchOS 8+.
2. **Open the workspace** – double-click `AvApp/AvApp.xcodeproj`. Xcode detects the local package under `Packages/AvAppNetworking` automatically.
3. **Add credentials** – replace the placeholder RapidAPI keys inside `Packages/AvAppNetworking/Sources/AvAppNetworking/FlightService.swift` and `AircraftService.swift` with your own. Consider moving them into an `xcconfig` or using secrets in the future.
4. **Run** – select the `AvApp` scheme and target a simulator or device. The `ContentView` will automatically fetch departures/arrivals for the default airport code (MCO).

## Development tips
- Use the `FlightViewModel` entry point for UI-driven fetches. It exposes `fetchFlights(for:)` so previews/tests can inject known data.
- `FlightService` now centralizes both departure and arrival queries. Mock data lives in `FlightMocks.swift` for previews/tests.
- Extend the directory layout by adding new folders under `Features/<FeatureName>`; share code via `Shared/` or the networking package when possible.
- For debugging network responses, enable the mock helpers or log raw payloads from the `NetworkClient`.

## Testing
- From Xcode: `⌘U` runs `AvAppTests` and `AvAppUITests`.
- Package tests: `swift test --package-path Packages/AvAppNetworking`.

## Further reading
- `docs/ARCHITECTURE.md` — rationale behind the layered structure plus extension guidelines.

## Next steps
- Externalize RapidAPI secrets via `xcconfig` or environment variables.
- Expand MapKit integration by reusing the networking package for live flight positions.
- Add snapshot/UI tests covering the tabbed flight list flow.
