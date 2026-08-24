

# **AvApp – Fastlane Automation Documentation**

## **1. Goal & Purpose of Fastlane in AvApp**

Fastlane is used in AvApp to:

* Run **unit + UI tests** and **snapshot runs** in a **repeatable**, simulator-stable environment
* Provide a **single command** (`bundle _2.7.2_ exec fastlane tests`) that handles:

  * Simulator config
  * Running the full test suite
  * Exporting result bundles for review
* Enable **future CI integration** (GitHub Actions, Bitrise, Jenkins)

Fastlane simplifies QA verification and ensures AvApp’s UI remains stable across iterations.

---

# **2. Machine Setup (One-Time)**

Fastlane lanes rely on Xcode, iOS simulators, and the repo-pinned Ruby gems.

1) Install Xcode and the iOS simulator runtime for iOS 17.x (Xcode > Settings > Platforms).
2) Launch Xcode once to accept licenses and install components.
3) Ensure the command line tools point at Xcode:
```
xcode-select -p
```
4) Install Homebrew Ruby (recommended) to match Bundler 2.7.x:
```
brew install ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```
5) Install Bundler 2.7.2 for that Ruby:
```
gem install bundler -v 2.7.2 --user-install
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"   # adjust if your gem path differs
```
6) From `AvApp/AvApp`, install gems:
```
bundle _2.7.2_ install --path vendor/bundle
```

---

# **3. Fastlane Folder Structure**

```
fastlane/
  Fastfile         # Lanes
  Appfile          # Basic metadata (bundle id, Apple ID)
  SnapshotHelper.swift (generated)
```

Developers run Fastlane through Bundler from `AvApp/AvApp`:

```bash
bundle _2.7.2_ exec fastlane <lane>
```

---

# **4. Fastfile Lanes**

## **4.1 `tests` (primary lane)**

Runs the full **unit + UI test suite** on a known simulator.

```ruby
lane :tests do
  run_tests(
    project: "AvApp.xcodeproj",
    scheme: "AvApp",
    devices: [ENV["SIMULATOR_DEVICE"] || "iPhone 17 Pro"],
    clean: true,
    result_bundle: true,
    xcargs: "-parallel-testing-enabled NO"
  )
end
```

### Why this matters:

* Ensures consistent simulator runtime
* Disables parallel UI tests → reduces flakiness
* Cleans before running → avoids cache-related UI mismatches
* Works identically locally and in CI

---

## **4.2 `quick_tests` (smoke testing lane)**

Lightweight smoke tests on a selected device:

```ruby
lane :quick_tests do
  scan(
    project: "AvApp.xcodeproj",
    scheme: "AvApp",
    devices: [ENV["SIMULATOR_DEVICE"] || "iPhone 17 Pro"]
  )
end
```

Used during rapid development to confirm that navigation and basic UI still load.

---

## **4.3 `snapshot` (UI screenshots lane)**

Runs UI tests with deterministic data and captures screenshots:

```ruby
lane :snapshot do
  snapshot(
    project: "AvApp.xcodeproj",
    scheme: "AvApp",
    devices: [ENV["SIMULATOR_DEVICE"] || "iPhone 17 Pro"],
    languages: ["en-US"],
    clear_previous_screenshots: true,
    override_status_bar: true,
    xcargs: "-ui_testing_screenshots"
  )
end
```

This lane is used for marketing or QA snapshot verification.

---

## **4.4 `demo` / `hello` / `world` (presentation lanes)**

Simple lanes used for teaching/demo purposes:

```ruby
lane :demo do
  puts "🚀 Fastlane Demo Running!"
  version = get_version_number(xcodeproj: "AvApp.xcodeproj")
  puts "📦 Current version: #{version}"
end
```

Useful for showing:

* lane structure
* running Fastlane actions
* how Ruby scripting integrates with Fastlane

---

# **5. Deterministic UI & Snapshot Test Support**

Snapshot lane runs with launch arguments such as:

* `-ui_testing_screenshots`

Inside AvApp, these flags activate the **mock data layer**, ensuring:

* No network calls
* Stable, predictable UI structure
* Identical snapshots across machines
* Zero flakiness when running through Fastlane

Fastlane doesn't generate the UI itself — it orchestrates:

1. launching the simulator
2. installing the app
3. injecting arguments
4. running tests/snapshots
5. collecting results

This is how Fastlane guarantees reproducibility across environments.

---

# **6. Running Tests with Fastlane**

## **Full Suite**

```bash
bundle _2.7.2_ exec fastlane tests
```

What happens:

* Boot simulator → iPhone 17 Pro (or `SIMULATOR_DEVICE`)
* Build app
* Run unit tests
* Run UI tests
* Export result bundle

---

## **Smoke Tests**

```bash
bundle _2.7.2_ exec fastlane quick_tests
```

Runs a small set of tests without the full overhead.

---

## **Snapshots**

```bash
bundle _2.7.2_ exec fastlane snapshot
```

Captures deterministic UI screenshots with mock data.

---

# **7. Example CI Integration (Future)**

Fastlane is CI-ready because all automation is wrapped in lanes.

Example GitHub Actions step:

```yaml
- name: Run Fastlane Tests
  run: bundle _2.7.2_ exec fastlane tests
```

Fastlane does all the heavy lifting:

* Simulator config
* Build
* UI tests
* Snapshot collection
* Result-bundle export

---

# **8. Why Fastlane Works Well for AvApp**

### **✔ Deterministic Testing**

Mock layer + launch flags ensures AvApp tests run identically every time.

### **✔ Declarative Automation**

Lanes abstract away:

* simulator model
* flags
* project paths
* test configuration

### **✔ Reproducible Verification**

Senior devs/QAs can review the app by simply running:

```bash
bundle _2.7.2_ exec fastlane tests
```

### **✔ Presentation-Friendly**

The lightweight `demo` lane allows safe, quick fastlane walkthroughs during reviews.

---
