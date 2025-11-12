# Architecture notes

## Layers at a glance
```
┌──────────────────────────────────────┐
│           UI/Presentation            │  SwiftUI views (ContentView, FlightListView) + view models
├──────────────────────────────────────┤
│            Domain Models             │  `FlightData`, `FlightSegment`, `AircraftDetail`
├──────────────────────────────────────┤
│          Networking Package          │  `Packages/AvAppNetworking`
└──────────────────────────────────────┘
```

- **SwiftUI layer** (`AvApp/Features/**`) owns state management via observable view models. It should not construct raw `URLRequest` objects; instead it calls `FlightService` and `AircraftService` abstractions.
- **Domain models** live in the package so both the app and previews/tests share identical types.
- **Networking** uses a protocol-driven `NetworkClient` to support URLSession as well as in-memory mocks.

## Directory contracts
| Path | Purpose | Notes |
| --- | --- | --- |
| `AvApp/Features/MVP` | Shipping flight list implementation. | Contains `Views/` and `ViewModel/` folders for clarity. |
| `AvApp/Features/MapKitInteg` | Experimental map integration. | Keep prototypes here until they are stable enough to merge into `MVP`. |
| `Packages/AvAppNetworking` | Source of truth for all API interactions. | Houses `Sources/AvAppNetworking/Models`, `Services`, and `Support` folders. |
| `AvAppTests`, `AvAppUITests` | Mirror app folder names for easier test discovery. | Tests can `@testable import AvApp` and `import AvAppNetworking`. |

## Package structure
```
Packages/AvAppNetworking
├── Package.swift
├── Sources/AvAppNetworking
│   ├── Services
│   │   ├── FlightService.swift
│   │   └── AircraftService.swift
│   ├── Client
│   │   ├── NetworkClient.swift
│   │   └── NetworkError.swift
│   ├── Models
│   │   ├── FlightModels.swift
│   │   └── AircraftDetail.swift
│   └── Support
│       └── FlightMocks.swift
└── Tests/AvAppNetworkingTests
```

## Dependency guidelines
- UI targets can only depend on the Swift package via `import AvAppNetworking`.
- Do not leak RapidAPI keys from the package; inject them (future improvement: `Secrets.plist`).
- When adding new endpoints, place DTOs in `Models/`, request orchestration in `Services/`, and re-use `NetworkClient` helpers instead of calling `URLSession.shared` directly.

## Adding a new feature folder
1. Create `AvApp/Features/<FeatureName>/Views` and `.../ViewModel` (plus `Models` if needed).
2. Keep view models small; extract shared logic into either `Shared/` under the feature or the networking package if it needs backend data.
3. Document the feature in this file once it ships so future contributors know where to look.
