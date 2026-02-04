#!/bin/bash
# template_engine.sh - Process .tmpl files with variable substitution
#
# Simplified version: Beads is required, so no conditional processing needed.
# Templates should not contain {{#if}} or {{#unless}} blocks.

# Process a single template file
# Usage: process_template input.tmpl output.md
process_template() {
    local input_file="$1"
    local output_file="$2"

    if [[ ! -f "$input_file" ]]; then
        echo "ERROR: Template not found: $input_file" >&2
        return 1
    fi

    local content
    content=$(cat "$input_file")

    # Variable substitution (paths only)
    content="${content//\$\{CHAOS_ROOT\}/$CHAOS_ROOT}"
    content="${content//\$\{PROJECT_ROOT\}/$PROJECT_ROOT}"

    # Ensure output directory exists
    mkdir -p "$(dirname "$output_file")"

    echo "$content" > "$output_file"
}

# Process all templates in a directory
# Usage: process_template_dir source_dir dest_dir
process_template_dir() {
    local source_dir="$1"
    local dest_dir="$2"
    local count=0

    # Find all .tmpl files
    while IFS= read -r -d '' template; do
        local relative_path="${template#$source_dir/}"
        local output_path="$dest_dir/${relative_path%.tmpl}"

        process_template "$template" "$output_path"
        ((count++))
    done < <(find "$source_dir" -name "*.tmpl" -type f -print0 2>/dev/null)

    # Also copy non-template files as-is
    while IFS= read -r -d '' file; do
        local relative_path="${file#$source_dir/}"
        local output_path="$dest_dir/$relative_path"

        mkdir -p "$(dirname "$output_path")"
        cp "$file" "$output_path"
    done < <(find "$source_dir" -type f ! -name "*.tmpl" -print0 2>/dev/null)

    echo "$count"
}
