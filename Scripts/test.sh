#!/bin/bash
# Run every test through the Kyosaku scheme.
# Usage: Scripts/test.sh [--skip-ui] [BUILD_SETTING=value ...]
set -euo pipefail
cd "$(dirname "$0")/.."

skip_ui=false
build_settings=()
for argument in "$@"; do
    case "$argument" in
        --skip-ui) skip_ui=true ;;
        *=*) build_settings+=("$argument") ;;
        *)
            echo "usage: Scripts/test.sh [--skip-ui] [BUILD_SETTING=value ...]" >&2
            exit 2
            ;;
    esac
done

result_bundle=build/TestResults.xcresult
rm -rf "$result_bundle"
mkdir -p build

test_arguments=(
    -project Kyosaku.xcodeproj
    -scheme Kyosaku
    -destination "platform=macOS,arch=arm64"
    -derivedDataPath build/DerivedData
    -resultBundlePath "$result_bundle"
)
if [ "$skip_ui" = true ]; then
    test_arguments+=(-skip-testing:KyosakuUITests)
fi

# The ${array[@]+...} form keeps an empty array from tripping `set -u` in macOS's bash 3.2.
xcodebuild test -quiet "${test_arguments[@]}" ${build_settings[@]+"${build_settings[@]}"}
