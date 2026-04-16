#!/usr/bin/env bash
# PlantUML Image Generator
# Finds all .puml files recursively and generates PNG images under the Generated/ folder,
# preserving the original folder structure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANTUML_JAR="${PLANTUML_JAR:-$SCRIPT_DIR/plantuml.jar}"
OUTPUT_ROOT="$SCRIPT_DIR/Generated"
FORMAT="${FORMAT:-png}"

# Verify java is available
if ! command -v java &>/dev/null; then
  echo "Error: Java is not installed or not in PATH." >&2
  exit 1
fi

# Verify plantuml.jar exists
if [ ! -f "$PLANTUML_JAR" ]; then
  echo "Error: plantuml.jar not found at: $PLANTUML_JAR" >&2
  echo "Download it from https://plantuml.com/download and place it in the repository root." >&2
  exit 1
fi

success=0
fail=0

# Find all .puml files, excluding the Generated/ directory
while IFS= read -r -d '' file; do
  dir="$(dirname "$file")"
  relative_dir="${dir#$SCRIPT_DIR}"
  relative_dir="${relative_dir#/}"

  if [ -n "$relative_dir" ]; then
    output_dir="$OUTPUT_ROOT/$relative_dir"
  else
    output_dir="$OUTPUT_ROOT"
  fi

  mkdir -p "$output_dir"
  echo "Generating [$FORMAT] for: ${relative_dir:-.}/$(basename "$file") ..."

  if java -jar "$PLANTUML_JAR" "-t$FORMAT" -o "$output_dir" "$file"; then
    success=$((success + 1))
  else
    echo "Warning: failed to generate image for $file" >&2
    fail=$((fail + 1))
  fi
done < <(find "$SCRIPT_DIR" -name "*.puml" -not -path "*/Generated/*" -print0)

echo ""
echo "Done. Success: $success | Failed: $fail"
echo "Images saved to: $OUTPUT_ROOT"
