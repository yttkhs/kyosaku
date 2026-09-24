# Architecture

How Kyosaku is put together. Conventions for writing code are in [AGENTS.md](../AGENTS.md).

## Layers

```
KyosakuCore             Pure logic. Foundation only, and fully covered by unit tests.
    ↑ used by
App services            System integration in Kyosaku/Platform/ and each feature's folder.
    ↑ owned by
AppRoot + coordinators  @MainActor and @Observable. The only owners of long-lived state.
    ↑ observed by
Views                   SwiftUI. Thin: they render state and call coordinators.
```

A decision that needs neither the UI nor a system API belongs in `KyosakuCore`, where it is tested in
isolation. The app target holds everything that touches AppKit, SwiftUI, the accessibility API, Apple
events, notifications or storage.

## The composition root

`AppDelegate` creates the one `AppRoot` with `LaunchOptions.current` and calls `start()` when the app has
finished launching. `start()` is the whole launch sequence, so reading it tells you what Kyosaku does at
startup. `AppRoot` is not a singleton, so tests can build their own.

`start()` first opens the SwiftData store and builds `TasksCoordinator` on it. The unit test host skips
`start()`, so the tests never open the Dev app's own store.

Coordinators are `@ObservationIgnored` lazy properties of `AppRoot`, so reading one never makes a view
redraw. `tasks` is the exception: `start()` creates it, and it is observed, so that the menu bar icon
redraws once the tasks are open. Views get `AppRoot` from the environment (`@Environment(AppRoot.self)`)
and call a coordinator; a view never mutates state or decides policy itself.

## Windows

- **The popover** is the app's only scene: a `MenuBarExtra` with the `.window` style.
- **Settings and the first-launch welcome** are titled windows owned by `AppWindowController`, each through
  its coordinator. SwiftUI's `Settings` scene is not used, because a menu bar agent cannot reliably bring it
  to the front. The Settings window uses `NSTabViewController` with toolbar tabs, each hosting a SwiftUI
  pane.
- **The Dock icon** appears only while at least one of those windows is open, so that ⌘Tab and the Dock can
  reach them. `ActivationPolicy` switches between `.regular` and `.accessory`, tracking windows by identity.

## Concurrency

- Swift 6 language mode everywhere, so data races are compile-time errors.
- The app and its unit tests default to `@MainActor` isolation, with Approachable Concurrency turned on.
- `KyosakuCore` has no default isolation and enables `NonisolatedNonsendingByDefault` and
  `InferIsolatedConformances`, so that its async functions behave the same way as the app's.
- Kyosaku does no periodic work. Changes arrive as system notifications, and timers are scheduled for the
  moment something is due.

## Where data lives

These are the rules for every feature. So far, SwiftData holds the tasks, and UserDefaults holds the task
in progress and whether the welcome was shown.

The store is `Kyosaku.store` in `~/Library/Application Support/<bundle ID>/`, so the Dev app and an
installed Kyosaku never share it. Until the first release, `KyosakuSchemaV1` may still change; after it,
every change adds a schema version and a migration stage to `KyosakuMigrationPlan`.

| Where | What |
| --- | --- |
| SwiftData, in the app's own folder under Application Support | Tasks, allow-list templates and daily counts: only what the user entered or did |
| UserDefaults | Settings and small state, such as the task in progress and whether the welcome was shown |
| Memory only | What is on screen, relevance judgments and their cache, and the distraction meter |
| Never | Page addresses, window titles and judgments on disk, in logs without `privacy: .private`, or in notifications |

## Adding a feature

1. Put logic that needs neither UI nor system APIs in `KyosakuCore`, test-first.
2. Put system integration and views in `Kyosaku/Features/<Name>/`, and shared system wrappers in
   `Kyosaku/Platform/`.
3. Give the feature a coordinator on `AppRoot`, and wire it in `start()` if it runs at launch.
4. Update this document and [docs/testing.md](testing.md) if the change makes them wrong.
