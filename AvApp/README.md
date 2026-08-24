# AvApp

AvApp is a SwiftUI-based flight tracker that surfaces airport departures/arrivals and per-aircraft details backed by the AeroDataBox RapidAPI. The UI is intentionally simple so that new features (like MapKit overlays) can be layered on top of a clean, testable networking core.

## Tech stack
- SwiftUI + NavigationStack + TabView for UI structure
- MapKit for the upcoming airport radar/map integration
- Swift Concurrency (`async`/`await`) for flight fetching and background updates
- Swift Package Manager for the reusable networking layer (`Packages/AvAppNetworking`)
- XCTest targets (`AvAppTests`, `AvAppUITests`, `Packages/AvAppNetworking/Tests`)

## Feature highlights
- Flight board listing departures and arrivals with filtering, search suggestions, and loading/error states.
- Aircraft detail drill-down backed by `AircraftService`, sharing the same networking/core models as the board.
- In-progress MapKit integration (gated behind `Features/MapKitInteg`) for experimenting with radar overlays.
- Shared networking package (`AvAppNetworking`) that can power other Swift targets or playground spikes.

## Directory layout
```
AvApp/
├── AvApp/                      # App target sources (SwiftUI views, view models, Assets)
│   └── Features/
│       ├── FlightBoard/        # Shipping departures/arrivals MVVM-C feature
│       ├── AircraftDetail/     # Aircraft detail MVVM-C flow
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
| `AvApp` | User interface, app lifecycle, feature composition | Depends on `AvAppNetworking` for data and exposes feature folders (`Features/FlightBoard`, `Features/AircraftDetail`, `Features/MapKitInteg`). |
| `AvAppNetworking` | Fetches flight/aircraft data from RapidAPI with strong typing and detailed errors. | Distributed as a Swift package inside `Packages/`; shared clients can re-use it. |
| `AvAppTests` / `AvAppUITests` | Regression and UI coverage. | Adopt the same folder naming as the app target so files are easy to locate. |

## Getting started
1. **Install tools** – Xcode 16.0+ (Swift 6 toolchain). The package manifest targets iOS 15+, macOS 12+, tvOS 15+, watchOS 8+.
2. **Open the workspace** – double-click `AvApp/AvApp.xcodeproj`. Xcode detects the local package under `Packages/AvAppNetworking` automatically.
3. **Add credentials** – replace the placeholder RapidAPI keys inside `Packages/AvAppNetworking/Sources/AvAppNetworking/FlightService.swift` and `AircraftService.swift` with your own. Consider moving them into an `xcconfig` or using secrets in the future.
4. **Run** – select the `AvApp` scheme and target a simulator or device. `FlightBoardView` boots through the `FlightBoardCoordinator` and automatically fetches departures/arrivals for the default airport code (MCO).

## Configuration & environment
| What | How | Notes |
| --- | --- | --- |
| RapidAPI key | Replace the `apiKey` constants in `FlightService.swift` and `AircraftService.swift` or inject them when creating the services. | Keep secrets out of source control; Xcode `xcconfig` files or environment variables + `ProcessInfo.processInfo.environment` work well. |
| Default airport | Update `FlightBoardCoordinator(airportCode:)` default or inject at the composition root (`AvAppApp`). | Airport suggestions shown in `FlightBoardAirportSearchBar.defaultSuggestions`. |
| Mock data | `Packages/AvAppNetworking/Sources/AvAppNetworking/Support/FlightMocks.swift`. | Use for SwiftUI previews or offline demos. |
| Map experiments | Enable and iterate inside `AvApp/Features/MapKitInteg`. | Ship-ready code should eventually move into its own feature folder. |

### Command line builds
CLI workflows are helpful for CI or scripted smoke tests.

```bash
# Resolve packages and build the app target
xcodebuild \
  -project AvApp.xcodeproj \
  -scheme AvApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# Package-only tests
swift test --package-path Packages/AvAppNetworking
```

## Development tips
- Use `FlightBoardViewModel` (wired through `FlightBoardCoordinator`) for departures/arrivals. Inject mocks into the coordinator when running previews or unit tests.
- `FlightService` now centralizes both departure and arrival queries. Mock data lives in `FlightMocks.swift` for previews/tests.
- Extend the directory layout by adding new folders under `Features/<FeatureName>`; share code via `Shared/` or the networking package when possible.
- For debugging network responses, enable the mock helpers or log raw payloads from the `NetworkClient`.

## Testing
- From Xcode: `⌘U` runs `AvAppTests` and `AvAppUITests`.
- Package tests: `swift test --package-path Packages/AvAppNetworking`.

## Troubleshooting
- **No flights shown / empty list** – confirm RapidAPI quota, watch the Xcode console for `NetworkError` descriptions, and try a different airport code (e.g. JFK or LAX).
- **403 errors** – your RapidAPI key is invalid or missing; make sure both `FlightService` and `AircraftService` share the same updated key.
- **Package fails to resolve** – run `File > Packages > Reset Package Caches` or delete `DerivedData`. CI should use `xcodebuild -resolvePackageDependencies`.
- **MapKit previews crash** – the prototype layer still assumes simulator availability; wrap MapKit code in `#if canImport(MapKit)` blocks if targeting macOS previews.

## Further reading
- `docs/ARCHITECTURE.md` — rationale behind the layered structure plus extension guidelines.

## Documentation map
- `docs/ARCHITECTURE.md` – layering, dependency rules, and coordinator guidance.
- `Packages/AvAppNetworking/README.md` *(add as needed)* – include endpoint specifics if the package is published separately.
- Inline doc comments on `FlightService`, `AircraftService`, and `FlightBoardViewModel` describe threading and data refresh behavior.

## Contributing
1. Use feature branches and keep commits scoped to a single concern (e.g. “Add arrivals filter”).
2. Run `⌘U` (or `xcodebuild test`) plus `swift test --package-path Packages/AvAppNetworking` before opening a PR.
3. Update this README and `docs/ARCHITECTURE.md` whenever you add a feature or change a public API.
4. Prefer protocol-driven additions so networking logic remains testable without live network calls.

## Next steps
- Externalize RapidAPI secrets via `xcconfig` or environment variables.
- Expand MapKit integration by reusing the networking package for live flight positions.
- Add snapshot/UI tests covering the tabbed flight list flow.
