

# **AvApp – Fastlane Automation Documentation**

## **1. Goal & Purpose of Fastlane in AvApp**

Fastlane is used in AvApp to:

* Run **unit + UI + snapshot tests** in a **repeatable**, simulator-stable environment
* Provide a **single command** (`bundle exec fastlane tests`) that handles:

  * Simulator config
  * Mock injection via launch flags
  * Running UI tests with deterministic data
  * Capturing snapshots (if enabled)
  * Exporting result bundles for review
* Enable **future CI integration** (GitHub Actions, Bitrise, Jenkins)

Fastlane simplifies QA verification and ensures AvApp’s UI remains stable across iterations.

---

# **2. Fastlane Folder Structure**

```
fastlane/
  Fastfile         # Lanes
  Appfile          # Basic metadata (bundle id, Apple ID)
  SnapshotHelper.swift (generated)
```

Developers run Fastlane through Bundler:

```bash
bundle exec fastlane <lane>
```

---

# **3. Fastfile Lanes**

## **3.1 `tests` (primary lane)**

Runs the full **unit + UI test suite** on a known simulator.

```ruby
lane :tests do
  run_tests(
    project: "AvApp.xcodeproj",
    scheme: "AvApp",
    clean: true,
    parallel_testing: false,
    device: ENV["SIMULATOR_DEVICE"] || "iPhone 15 Pro"
  )
end
```

### Why this matters:

* Ensures consistent simulator runtime
* Disables parallel UI tests → reduces flakiness
* Cleans before running → avoids cache-related UI mismatches
* Works identically locally and in CI

---

## **3.2 `quick_tests` (smoke testing lane)**

Lightweight smoke tests on a selected device:

```ruby
lane :quick_tests do
  scan(
    scheme: "AvApp",
    device: "iPhone 15"
  )
end
```

Used during rapid development to confirm that navigation and basic UI still load.

---

## **3.3 `demo` / `hello` / `world` (presentation lanes)**

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

# **4. Deterministic UI & Snapshot Test Support**

Fastlane triggers the UI test target with flags such as:

* `-ui_testing`
* `-ui_testing_screenshots`
* `-FASTLANE_SNAPSHOT`

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

# **5. Running Tests with Fastlane**

## **Full Suite**

```bash
bundle exec fastlane tests
```

What happens:

* Boot simulator → iPhone 15 Pro
* Build app
* Run unit tests
* Run UI tests
* Capture snapshots (if snapshot scheme enabled)
* Export result bundle

---

## **Smoke Tests**

```bash
bundle exec fastlane quick_tests
```

Runs a small set of tests without the full overhead.

---

# **6. Example CI Integration (Future)**

Fastlane is CI-ready because all automation is wrapped in lanes.

Example GitHub Actions step:

```yaml
- name: Run Fastlane Tests
  run: bundle exec fastlane tests
```

Fastlane does all the heavy lifting:

* Simulator config
* Build
* UI tests
* Snapshot collection
* Result-bundle export

---

# **7. Why Fastlane Works Well for AvApp**

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
bundle exec fastlane tests
```

### **✔ Presentation-Friendly**

The lightweight `demo` lane allows safe, quick fastlane walkthroughs during reviews.

---



