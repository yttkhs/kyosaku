# Shared by the Swift tooling scripts. Sourced, never run on its own.

# Prints, one per line, every path that holds Swift sources and exists right now.
swift_source_paths() {
    local path
    for path in Kyosaku KyosakuCore/Package.swift KyosakuCore/Sources KyosakuCore/Tests \
        KyosakuTests KyosakuUITests; do
        if [ -e "$path" ]; then
            printf '%s\n' "$path"
        fi
    done
}

# The swift-format bundled with the selected Xcode, so the editor and these scripts always agree.
find_swift_format() {
    xcrun --find swift-format 2>/dev/null || {
        echo "error: swift-format was not found in the selected Xcode; check 'xcode-select -p'" >&2
        return 1
    }
}
