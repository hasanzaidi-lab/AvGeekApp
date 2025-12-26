# Fastlane Guide for AvApp

## What’s included
- **Tests lane** (`tests` / alias `test`): Runs all unit + UI tests via `run_tests` on `AvApp.xcodeproj` / `AvApp`.
- **Snapshot lane** (`snapshot`): Generates screenshots using UI tests seeded with mock data (`-ui_testing_screenshots`), cleans old shots, overrides status bar.
- **Quick smoke** (`quick_tests`): Lightweight `scan` run on a simulator.
- Demo/hello/world lanes remain for simple examples.

## Machine setup (one-time)
1) Install Xcode and the iOS simulator runtime for iOS 17.x (Xcode > Settings > Platforms).
2) Launch Xcode once to accept licenses and install components.
3) Ensure the command line tools point at Xcode:
```
xcode-select -p
```
4) Use Homebrew Ruby (recommended) to match Bundler 2.7.x:
```
brew install ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```
5) Install Bundler 2.7.2 for that Ruby:
```
gem install bundler -v 2.7.2 --user-install
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"   # adjust if your gem path differs
```
6) From `AvApp/AvApp`, install gems with the pinned logger (1.6.0):
```
bundle _2.7.2_ install --path vendor/bundle
```

## Running lanes (always via Bundler)
Run from `AvApp/AvApp` so Bundler picks up the repo Gemfile.
- Full suite: `bundle _2.7.2_ exec fastlane test` (alias of `tests`)
  - Uses simulator `iPhone 17 Pro` by default; override with `SIMULATOR_DEVICE="iPhone 15 Pro"` (env var).
  - Cleans, produces a result bundle, disables parallel testing via `-parallel-testing-enabled NO`.
- Snapshots: `bundle _2.7.2_ exec fastlane snapshot`
  - Uses `AvApp` scheme, `-ui_testing_screenshots` to activate UI-test mocks, device default `iPhone 17 Pro` (override via `SIMULATOR_DEVICE`), language `en-US`, clears previous shots, overrides status bar.
- Quick smoke: `bundle _2.7.2_ exec fastlane quick_tests`
- Demo: `bundle _2.7.2_ exec fastlane demo`

## How screenshots stay deterministic
- Snapfile sets scheme to `AvApp` and launch args `-ui_testing_screenshots`.
- App detects those args via `UITestConfig.isUITesting` and serves mock flights, aircraft detail, and track data; no network dependency during snapshots.
- Accessibility identifiers (`flight-row`, `aircraft-detail-list`, `track-map`) keep XCUITest lookup stable.

## Troubleshooting
- **Logger recursion / stack overflow**: Ensure you run through `bundle exec` so fastlane uses the bundled `logger 1.6.0`, not the global `logger 1.7.x`.
- **Bundler version mismatch**: If Bundler 2.7.2 isn’t found, install it for your Homebrew Ruby as above and call commands with `bundle _2.7.2_ ...`.
- **Simulator not found**: Set `SIMULATOR_DEVICE` to a device installed in Xcode (e.g., `"iPhone 16 Pro"`).
