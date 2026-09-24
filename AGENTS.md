# Kyosaku

Kyosaku is a macOS menu bar app that helps you stay on task. While a task is in progress, it compares what
is on your screen — the frontmost app, the window title and the page address — with the task, using
Apple's on-device Foundation Models, and gently nudges you when you drift. It never blocks anything, and
nothing you look at leaves your Mac.

SwiftUI and AppKit, Swift 6, macOS 26 or later, running as a menu bar agent (`LSUIElement`), with no
third-party dependencies.

## Posture

- **One platform: macOS 26 or later, on Apple silicon with Apple Intelligence.** Use the newest Apple API
  for the job — Observation, Swift Concurrency, `SMAppService` — and add no shims, fallbacks or version
  checks for older systems.
- **No third-party dependencies** until a built-in framework clearly falls short. Then add the smallest one
  that closes the gap, and explain why in the pull request.
- **Delete rather than deprecate.** Dead code and compatibility paths are removed, not kept "just in case".

## Where things are

| Path | Holds |
| --- | --- |
| `Kyosaku/App/` | `KyosakuApp` (`@main`), `AppDelegate` and `AppRoot`, the composition root |
| `Kyosaku/Features/` | One folder per feature: its views, its coordinator and its app-side logic |
| `Kyosaku/Platform/` | Small wrappers over system behavior, such as `ActivationPolicy` and `LaunchOptions` |
| `Kyosaku/Windows/` | `AppWindowController`, the owner of each titled window |
| `Kyosaku/Storage/` | The SwiftData schema, and the code that opens the one store every feature shares |
| `Kyosaku/Resources/` | `Localizable.xcstrings` |
| `KyosakuCore/` | The local Swift package with the logic that needs neither UI nor system APIs |
| `KyosakuTests/`, `KyosakuUITests/` | App unit tests (Swift Testing) and UI tests (XCUITest) |
| `Configs/` | The signing xcconfig files and the entitlements |
| `Scripts/` | `test.sh`, `lint.sh`, `format.sh` and `verify-signature.sh` |
| `docs/` | Architecture, development and testing guides |

| Read it before you | Doc |
| --- | --- |
| change how anything is wired or owned | [docs/architecture.md](docs/architecture.md) |
| build, run or change project settings | [docs/development.md](docs/development.md) |
| claim a change is done | [docs/testing.md](docs/testing.md) |

## Non-negotiables

- **`KyosakuCore` imports Foundation only**: no AppKit, SwiftUI, SwiftData, FoundationModels or
  ApplicationServices. Anything from the environment, such as the clock, user defaults or file locations,
  is passed in.
- **`AppRoot` owns every long-lived object**, wired in `start()`. There is no other singleton. Views reach a
  feature through its coordinator and never decide policy themselves.
- **Observed data never touches disk.** Page addresses, window titles and relevance judgments stay in
  memory. Log an address or a title only with `privacy: .private`. A notification carries its own ID and
  the task ID, nothing else. Kyosaku makes no network connections and has no telemetry.
- **`project.yml` is the only place for build settings**, with `Configs/Kyosaku.xcconfig` for signing. After
  editing it, run `xcodegen generate` and commit both. Never change settings in Xcode's project editor.
- **Debug builds are their own app**: `Kyosaku Dev.app`, bundle ID `io.github.yttkhs.kyosaku.dev`. Keep
  anything persisted keyed by the bundle ID, so that the two apps never share state.
- **Everything committed is in English**: code, comments, docs, commit messages and pull requests. The only
  exceptions are content that must be Japanese, such as the AI prompt and the synthetic evaluation data,
  and each one gets an exception in `Scripts/lint.sh`.
- **Planning documents are never committed.** Design specs, implementation plans and research notes live
  outside the repository.

## Conventions

- A type's suffix says what it is:

  | Suffix | Means |
  | --- | --- |
  | `Coordinator` | A feature's actions, called by views and by `AppRoot` |
  | `Controller` | Owns one AppKit window or view controller |
  | `Store` | Owns persisted state and publishes it |
  | `Monitor` | Watches a system event stream and reports changes, without policy |
  | `Service` | A stateless capability that other types call |
  | `Provider` | Supplies a value from the environment when asked, such as the current time or the frontmost app |
  | `Policy` | A pure decision, with no state and no effects |
  | `Engine` | A pure evaluator from input to output |
  | `Session` | Holds one run from its start to its end, such as a task in progress |
  | `State` | Shared observable state that persists nothing itself |

- One top-level type per file, named after the type.
- Comments are rare, one line, and explain *why*, never *what*. Prefer a well-named type or function.
- The app and its unit tests default to `@MainActor`. Move heavy work off the main actor explicitly, with an
  actor or a `nonisolated` function.

## Before you finish

- `Scripts/test.sh` passes.
- `Scripts/lint.sh` passes.
- The build has no new warnings.
- `xcodegen generate` leaves no changes behind.
- Any doc that your change made wrong is fixed in the same pull request.
