#!/bin/bash
# template_engine.sh - Process .tmpl files with variable substitution
#
# Simplified version: Beads is required, so no conditional processing needed.
# Templates should not contain {{#if}} or {{#unless}} blocks.

# Escape special characters for sed replacement
# Usage: escaped=$(escape_for_sed "$string")
escape_for_sed() {
    printf '%s\n' "$1" | sed 's/[&/\]/\\&/g'
}

# Process a single template file
# Usage: process_template input.tmpl output.md
process_template() {
    local input_file="$1"
    local output_file="$2"

    if [[ ! -f "$input_file" ]]; then
        echo "ERROR: Template not found: $input_file" >&2
        return 1
    fi

    # Ensure output directory exists
    mkdir -p "$(dirname "$output_file")"

    # Escape paths for safe sed substitution (handles &, /, \ in paths)
    local escaped_chaos_root
    local escaped_project_root
    escaped_chaos_root=$(escape_for_sed "$CHAOS_ROOT")
    escaped_project_root=$(escape_for_sed "$PROJECT_ROOT")

    # Use sed for substitution (safer with special characters)
    sed -e "s|\${CHAOS_ROOT}|${escaped_chaos_root}|g" \
        -e "s|\${PROJECT_ROOT}|${escaped_project_root}|g" \
        "$input_file" > "$output_file"
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
