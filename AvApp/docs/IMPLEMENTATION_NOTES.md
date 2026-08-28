# Implementation notes

This document records the security, architecture, UI, and testing work introduced in the current refactor.

## Security and repository hygiene

- Added a repository-root `.gitignore` plus app-level exclusions for signing assets, local credentials, build products, Xcode/SwiftPM user state, and Fastlane reports.
- Removed tracked signing material, release archives, debug-symbol archives, generated test results, and user-specific Xcode files from version control.
- Removed the hardcoded RapidAPI credential from `FlightService`. The credential is now supplied at app composition time and is never stored in the networking package.
- Added ignored `Secrets.plist` and `Secrets.xcconfig` workflows. `AppSecrets.xcconfig` optionally includes the local xcconfig and forwards `RAPIDAPI_KEY` to the generated `RapidAPIKey` plist setting. The runtime lookup order is process environment, build setting, then local plist.
- The previously exposed key still exists in Git history and must be rotated at RapidAPI. Rewriting published history is intentionally not part of this change.

## Networking and concurrency

- `FlightService`, `AircraftService`, and `TrackService` use injected `NetworkClient` instances rather than shared service singletons or direct `URLSession` calls.
- Added `FlightFetching`, `AircraftFetching`, and `TrackFetching` protocols, plus `MockNetworkClient` and mock services for deterministic tests, previews, and UI-test injection.
- `NetworkClient` maps transport failures, invalid responses, HTTP status failures, and decoding failures to `NetworkError` consistently.
- Package DTOs are `Sendable` and expose initializers for safe fixture construction outside the package.
- View models are `@MainActor` and expose async load methods. Coordinators and views await those methods instead of creating unstructured background tasks.

## App composition and navigation

- `AvAppApp` creates an `AppSession` at the root. `AppDependencies` supplies live services or mocks through the SwiftUI environment.
- `FlightBoardCoordinator` retains airport/tab/navigation state and owns aircraft-detail routes, while `FlightBoardViewModel` remains the single owner of flight loading state.
- Airport codes are trimmed and uppercased before persistence and requests. The selected airport is stored through `AirportCodeStoring`.
- Aircraft detail and MapKit flows receive their service dependencies from the environment and use async coordinators.

## Flight board UI

- Broke the former large list view into `FlightListView`, `FlightRow`, `FlightTimelineView`, and `FlightFormatting`.
- The board provides search, empty states, pull-to-refresh, auto-refresh, loading feedback, accessible status content, and coordinator-driven aircraft selection.
- Detail and map states provide explicit retry and error handling.

## Test and delivery coverage

- Added package fixture tests for flight and aircraft payload decoding, request headers/URL normalization, missing credentials, status/transport errors, and OpenSky track requests.
- Added app unit tests for flight-board success/error states, airport sanitization and persistence, tab navigation, aircraft detail errors, and formatting behavior.
- Extended UI-test launch configuration with simulated network-error and empty-registration paths, with matching failure-path UI tests.
- Added a Fastlane package-test lane and GitHub Actions jobs for package tests and app unit tests.

## Validation performed

- `swift test` in `AvApp/Packages/AvAppNetworking` passes (8 tests).
- `xcodebuild -project AvApp/AvApp.xcodeproj -scheme AvApp -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build` succeeds.
- A temporary non-secret `RAPIDAPI_KEY` build setting resolves to the generated `RapidAPIKey` plist value.
