#!/bin/bash
# Format every Swift source in place with the swift-format bundled with Xcode.
# Usage: Scripts/format.sh
set -euo pipefail
cd "$(dirname "$0")/.."
source Scripts/common.sh

swift_format=$(find_swift_format)
paths=()
while IFS= read -r path; do
    paths+=("$path")
done < <(swift_source_paths)

if [ ${#paths[@]} -eq 0 ]; then
    echo "No Swift sources to format."
    exit 0
fi

"$swift_format" format --in-place --recursive --parallel --configuration .swift-format "${paths[@]}"
echo "Formatted ${#paths[@]} path(s)."
