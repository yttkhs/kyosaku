#!/bin/bash
# Check Swift formatting, and that everything in the repository is written in English.
# Usage: Scripts/lint.sh
set -euo pipefail
cd "$(dirname "$0")/.."
source Scripts/common.sh

status=0

swift_format=$(find_swift_format)
paths=()
while IFS= read -r path; do
    paths+=("$path")
done < <(swift_source_paths)
if [ ${#paths[@]} -gt 0 ]; then
    "$swift_format" lint --strict --recursive --parallel --configuration .swift-format "${paths[@]}" \
        || status=1
fi

# Content that must stay Japanese (the AI prompt, synthetic evaluation data) gets an exception here.
text_files=()
while IFS= read -r -d '' file; do
    case "$file" in
        *.swift | *.md | *.yml | *.yaml | *.json | *.sh | *.xcconfig | *.entitlements | *.xcstrings \
            | *.pbxproj | *.xcscheme | *.plist | *.txt | .gitignore | .swift-format | LICENSE) ;;
        *) continue ;;
    esac
    if [ -f "$file" ]; then
        text_files+=("$file")
    fi
done < <(git ls-files -z --cached --others --exclude-standard)

if [ ${#text_files[@]} -gt 0 ]; then
    perl -CS -e '
        my $found = 0;
        for my $file (@ARGV) {
            open(my $handle, "<:encoding(UTF-8)", $file) or next;
            while (my $line = <$handle>) {
                if ($line =~ /[\x{3000}-\x{303F}\x{3040}-\x{30FF}\x{3400}-\x{4DBF}\x{4E00}-\x{9FFF}\x{FF01}-\x{FF60}]/) {
                    print "$file:$.: contains Japanese text\n";
                    $found = 1;
                }
            }
            close($handle);
        }
        exit($found ? 1 : 0);
    ' "${text_files[@]}" || status=1
fi

if [ "$status" -eq 0 ]; then
    echo "Lint passed."
fi
exit "$status"
