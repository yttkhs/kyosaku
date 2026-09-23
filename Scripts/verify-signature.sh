#!/bin/bash
# Check that a release build is signed the way distribution requires. See docs/testing.md.
# Usage: Scripts/verify-signature.sh <path to .app> [--notarized]
set -uo pipefail

usage() {
    echo "usage: Scripts/verify-signature.sh <path to .app> [--notarized]" >&2
    exit 2
}

app="${1:-}"
[ -d "$app" ] || usage
notarized=false
case "${2:-}" in
    "") ;;
    --notarized) notarized=true ;;
    *) usage ;;
esac

expected_entitlement=com.apple.security.automation.apple-events
failures=0

check() {
    local description=$1
    shift
    if "$@" >/dev/null 2>&1; then
        echo "✓ $description"
    else
        echo "✗ $description" >&2
        failures=$((failures + 1))
    fi
}

entitlements_file=$(mktemp)
trap 'rm -f "$entitlements_file"' EXIT
codesign --display --entitlements - --xml "$app" >"$entitlements_file" 2>/dev/null
executable="$app/Contents/MacOS/$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app/Contents/Info.plist")"

has_hardened_runtime() {
    local details
    # Captured first: piped into grep -q, codesign dies of SIGPIPE and pipefail reports a failure.
    details=$(codesign --display --verbose=2 "$executable" 2>&1) || return 1
    grep -Eq 'flags=0x[0-9a-f]+\([^)]*runtime' <<<"$details"
}

lacks_get_task_allow() {
    ! /usr/libexec/PlistBuddy -c "Print :com.apple.security.get-task-allow" "$entitlements_file"
}

has_only_the_expected_entitlement() {
    local keys
    keys=$(python3 -c 'import plistlib, sys; print(" ".join(sorted(plistlib.load(open(sys.argv[1], "rb")))))' \
        "$entitlements_file") || return 1
    [ "$keys" = "$expected_entitlement" ] \
        && [ "$(/usr/libexec/PlistBuddy -c "Print :$expected_entitlement" "$entitlements_file")" = true ]
}

explains_apple_events() {
    [ -n "$(/usr/libexec/PlistBuddy -c 'Print :NSAppleEventsUsageDescription' "$app/Contents/Info.plist")" ]
}

check "the signature is valid (codesign --verify --deep --strict)" codesign --verify --deep --strict "$app"
check "the hardened runtime is enabled" has_hardened_runtime
check "get-task-allow is absent" lacks_get_task_allow
check "the only entitlement is $expected_entitlement" has_only_the_expected_entitlement
check "Info.plist explains why Kyosaku sends Apple events" explains_apple_events
if [ "$notarized" = true ]; then
    check "Gatekeeper accepts the app (spctl --assess)" spctl --assess --type execute "$app"
    check "the notarization ticket is stapled (stapler validate)" xcrun stapler validate "$app"
fi

if [ "$failures" -gt 0 ]; then
    echo "$failures check(s) failed." >&2
    exit 1
fi
echo "All checks passed."
