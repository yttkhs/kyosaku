# Testing

## Running the tests

```sh
Scripts/test.sh                  # every test: KyosakuCoreTests, KyosakuTests and KyosakuUITests
Scripts/test.sh --skip-ui        # everything except the UI tests
Scripts/test.sh SWIFT_TREAT_WARNINGS_AS_ERRORS=YES   # every test, failing on any warning, as CI does
swift test --package-path KyosakuCore   # only the package, without building the app
```

`Scripts/test.sh` saves the results to `build/TestResults.xcresult`. In Xcode, ⌘U runs the same three
targets.

The first UI test run on a Mac may ask for an administrator password to allow UI automation. The UI tests
move the pointer and type, so leave the Mac alone while they run.

## Test layers

| Layer | Covers | How | Where |
| --- | --- | --- | --- |
| 1. Unit | Logic in `KyosakuCore` and in the app | Swift Testing, with fake clocks and fake system services | Every build and CI |
| 2. Storage | Schema migration, retention limits and deleting all data | Temporary SwiftData stores | Every build and CI (once storage exists) |
| 3. UI | The main flows through the popover, Settings and the welcome | XCUITest, with launch options that replace system services | CI, and locally |
| 4. On-device | Apple Intelligence, the accessibility API, Apple events, notifications, sleep and login items | Signed builds on Macs running macOS 26 and 27, following a checklist | Locally, by hand |
| 5. Pre-release | Privacy, signing and relevance accuracy | The checks in "Release criteria" below | Locally, by hand |

Apple Intelligence does not run in virtual machines, so layers 4 and 5 always run on real Macs.

## Writing tests

- Never touch state that the Mac shares with the apps you use. Create scratch user defaults with
  `UserDefaults(suiteName:)` and a unique name, and remove them afterwards.
- Give every element a UI test touches an accessibility identifier named `<area>.<element>`, such as
  `menu.settingsButton` or `settings.pane.templates`. Only what AppKit draws itself, such as toolbar tabs
  and window titles, is found by its title.
- UI tests cannot import the app, so they repeat the launch arguments from `LaunchOptions`. Keep both in
  step.
- Unit tests of the app run inside `Kyosaku Dev.app`. They must not add `KyosakuCore` as a dependency of
  `KyosakuTests`: the app already links it, and a second copy would make its types distinct at run time.

## Continuous integration

`.github/workflows/ci.yml` runs on every pull request and every push to `main`, on GitHub's `macos-26`
runner: it checks that the Xcode project matches `project.yml`, runs `Scripts/lint.sh`, and runs
`Scripts/test.sh` with warnings treated as errors. When the tests fail, the run keeps the result bundle as
the `TestResults` artifact for seven days.

## Definition of done

- `Scripts/test.sh` passes.
- `Scripts/lint.sh` passes.
- The build has no new warnings.
- `xcodegen generate` leaves no changes behind.
- Any doc that the change made wrong is fixed.
- For a change you can see, you launched `Kyosaku Dev.app` and tried it.

## Release criteria

A release ships only when all of these hold:

- **Accuracy:** on the synthetic evaluation data, the false-nudge and missed-drift rates are no worse than
  the baseline measured during the pre-development verification.
- **Language errors:** at most 1% of checks fail with an unsupported-language error.
- **Latency:** the median and 95th-percentile check times from the menu bar app are recorded, and they are
  not much worse than in the previous release.
- **Privacy:** no page address or window title remains in storage, logs or notifications.
- **Devices:** layer 4 passes on both macOS 26 and macOS 27.
- **Signing:** `Scripts/verify-signature.sh <path to Kyosaku.app> --notarized` passes on the build that
  ships.
