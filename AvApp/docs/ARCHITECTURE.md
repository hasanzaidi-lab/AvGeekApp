# Architecture notes

## Layers at a glance
```
┌──────────────────────────────────────┐
│           UI/Presentation            │  SwiftUI coordinators + views (`FlightBoardView`, `AircraftDetailView`)
├──────────────────────────────────────┤
│            Domain Models             │  `FlightData`, `FlightSegment`, `AircraftDetail`
├──────────────────────────────────────┤
│          Networking Package          │  `Packages/AvAppNetworking`
└──────────────────────────────────────┘
```

- **SwiftUI layer** (`AvApp/Features/**`) owns state management via observable view models. It should not construct raw `URLRequest` objects; instead it calls `FlightService` and `AircraftService` abstractions.
- Coordinators drive navigation and aggregate shared state; each feature exposes a single coordinator entry point so future child flows can be composed without rewriting the views.
- **Domain models** live in the package so both the app and previews/tests share identical types.
- **Networking** uses a protocol-driven `NetworkClient` to support URLSession as well as in-memory mocks.

## Directory contracts
| Path | Purpose | Notes |
| --- | --- | --- |
| `AvApp/Features/FlightBoard` | Shipping departures/arrivals experience implemented with MVVM-C. | Contains `Coordinator/`, `ViewModels/`, and `Views/`. |
| `AvApp/Features/AircraftDetail` | Dedicated aircraft detail flow. | Also structured as MVVM-C to keep navigation isolated. |
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

## Data flow walkthrough
1. `AvAppApp` composes the root `FlightBoardCoordinator`, injecting the concrete `FlightService`/`AircraftService`.
2. A user picks or searches an airport in `FlightBoardAirportSearchBar`, which notifies the coordinator via a binding.
3. `FlightBoardViewModel` calls into `FlightService.fetchFlights`, awaiting results on a background thread while publishing state via `@Published` properties.
4. The SwiftUI view hierarchy renders list sections (departures/arrivals) and hands selection events back to the coordinator.
5. Selecting a row pushes the aircraft detail flow, which resolves `AircraftService` and fetches the details with identical networking primitives.

This loop keeps feature code purely declarative: views never hold networking references, and coordinators never decode JSON.

## Coordinator & navigation guidelines
- Each feature folder exposes a single `Coordinator` entry point (`FlightBoardCoordinator`, `AircraftDetailCoordinator`, etc.) that is responsible for wiring bindings, injecting services, and owning child coordinators.
- State that needs to survive navigation (e.g. selected airport) should live in the coordinator and be passed down as `ObservedObject`/`StateObject`.
- Keep coordinators small; delegate long-running work to view models or shared utilities so navigation logic stays easy to reason about.

## Extending the networking package
1. Add DTOs to `Packages/AvAppNetworking/Sources/AvAppNetworking/Models` to keep serialization code grouped.
2. Introduce new service types under `Services/` and conform them to `Sendable` when possible so they can be shared across threads.
3. Reuse `NetworkClient` for HTTP plumbing; inject custom clients in tests (`NetworkClientMock`) instead of reaching for URLSession directly.
4. Document the new endpoint at the bottom of this file and mirror the change in the root README so UIs know how to consume it.

## Testing strategy
- App target tests (`AvAppTests`) should drive coordinators and view models using injected mock services to prove navigation state changes.
- Package tests (`Packages/AvAppNetworking/Tests`) focus on serialization, error surfaces, and `NetworkClient` contract tests.
- UI tests (`AvAppUITests`) assert high-level flows (launch → fetch flights → push aircraft detail). They should stub networking by swapping in mock clients at app launch.

## Concurrency & threading notes
- Services use Swift concurrency; prefer marking them `Sendable` and avoid sharing mutable state across actors.
- `FlightService` currently exposes a `shared` singleton for convenience—inject explicit instances during testing to remove global coupling.
- When updating UI from async work, ensure publishers hop back to the main actor (`@MainActor` on view models) to keep SwiftUI happy.

## Adding a new feature folder
1. Create `AvApp/Features/<FeatureName>/Coordinator`, `.../ViewModels`, and `.../Views` (plus `Models` if needed).
2. Keep view models small; coordinators should own routing/state composition, and reusable logic lives in `Shared/` or the networking package.
3. Document the feature in this file once it ships so future contributors know where to look.
