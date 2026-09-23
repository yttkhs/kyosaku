# Development

## Requirements

- macOS 26 or later on Apple silicon
- Xcode 26
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## First-time setup

Create `Configs/Signing.local.xcconfig` with your own signing identity. The file is ignored by Git.

```
CODE_SIGN_STYLE = Automatic
CODE_SIGN_IDENTITY = Apple Development
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

Your team ID is the `OU` of your Apple Development certificate:

```sh
security find-certificate -c "Apple Development" -p | openssl x509 -noout -subject
```

Without this file the build is signed ad hoc. It still runs, but macOS forgets permissions such as
Accessibility every time you rebuild, because an ad hoc signature changes with every build.

## Build and run

Open `Kyosaku.xcodeproj` in Xcode and run the `Kyosaku` scheme, or build from the command line:

```sh
xcodebuild build -project Kyosaku.xcodeproj -scheme Kyosaku -configuration Debug \
    -derivedDataPath build/DerivedData
open "build/DerivedData/Build/Products/Debug/Kyosaku Dev.app"
```

### Kyosaku Dev

Debug builds are a separate app, `Kyosaku Dev.app`, with the bundle ID `io.github.yttkhs.kyosaku.dev`.
Its preferences, permissions and login item are its own, so a development build never reads or overwrites
the state of an installed Kyosaku.

To see the first-launch welcome again:

```sh
defaults delete io.github.yttkhs.kyosaku.dev hasSeenOnboarding
```

## Project settings

`project.yml` is the only place for build settings, and `Configs/Kyosaku.xcconfig` holds the signing
defaults. After editing either one, regenerate the project and commit the result:

```sh
xcodegen generate
```

The source folders are synchronized folders, so adding, moving or deleting a file needs no regeneration.
Never change settings in Xcode's project editor: the next `xcodegen generate` discards them, and CI fails
when the committed project does not match `project.yml`.

## Code style

```sh
Scripts/format.sh    # format the Swift sources in place
Scripts/lint.sh      # check formatting, and that everything committed is in English
```

Both use the swift-format bundled with Xcode, configured by `.swift-format`.

## Strings

User-facing strings live in `Kyosaku/Resources/Localizable.xcstrings`, with English as the source
language. Building in Xcode adds new strings to the catalog. A command-line build does not, but exporting
the localizations does:

```sh
xcodebuild -exportLocalizations -project Kyosaku.xcodeproj -scheme Kyosaku \
    -derivedDataPath build/DerivedData -localizationPath build/Localizations -exportLanguage en
```

Commit the catalog with the change that added the strings.

## Launch options

| Option | Effect |
| --- | --- |
| `-KyosakuUITesting` | Skips everything that touches the system. For now: the welcome is not shown or recorded |
| `-KyosakuMenuContentInWindow` | Shows the popover content in a normal window, so UI tests can reach it |
| `KYOSAKU_HOSTING_UNIT_TESTS=1` | Set by the scheme while unit tests run inside the app; `start()` is skipped |

## Troubleshooting

### codesign keeps asking for your password

If a command-line build makes `codesign` ask for your login password again and again, or fail with
`errSecInternalComponent`, your signing key does not yet let Apple's tools use it. Allow them on that key
alone, where `KEY_NAME` is the key's name under Keys in Keychain Access. This asks for your login password
once:

```sh
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -t private -l "KEY_NAME" \
    ~/Library/Keychains/login.keychain-db
```
