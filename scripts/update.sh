#!/bin/bash

INDEX_FILE=".mush/registry/index/github-javanile-mush.index"
PACKAGES_DIR="_packages"

mkdir -p "$PACKAGES_DIR"

while IFS= read -r line || [[ -n "$line" ]]; do
    # skip empty lines and comment-only lines
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # extract package name (first field)
    name=$(echo "$line" | awk '{print $1}')

    echo -n "Processing: ${name} ... "

    # run mush info and strip ANSI escape codes
    info=$(MUSH_HOME=$PWD/.mush mush info "$name" 2>&1 | sed 's/\x1b\[[0-9;]*m//g')

    # extract fields from mush info output
    github=$(echo "$info" | grep '^Repo:' | sed 's/^Repo:[[:space:]]*//')
    description=$(echo "$info" | grep '^Desc:' | sed 's/^Desc:[[:space:]]*//')
    path=$(echo "$info" | grep '^Path:' | sed 's/^Path:[[:space:]]*//')

    # fallback from index line if mush info didn't return data
    if [[ -z "$github" ]]; then
        github=$(echo "$line" | awk '{print $2}')
    fi
    if [[ -z "$description" ]]; then
        if [[ "$line" == *"#"* ]]; then
            description=$(echo "$line" | sed 's/.*#[[:space:]]*//')
            [[ "$description" == "(no description)" ]] && description=""
        fi
    fi

    # extract versions list (lines after "Versions:" that start with " - ")
    versions=$(echo "$info" | awk '/^Versions:/{found=1; next} found && /^ - /{print}' \
        | sed 's/^[[:space:]]*-[[:space:]]*//')

    # build YAML versions array
    versions_yaml=""
    while IFS= read -r ver; do
        [[ -z "$ver" ]] && continue
        versions_yaml="${versions_yaml}  - ${ver}"$'\n'
    done <<< "$versions"

    {
        echo "---"
        echo "name: ${name}"
        echo "description: \"${description}\""
        echo "github: ${github}"
        [[ -n "$path" ]] && echo "path: ${path}"
        if [[ -n "$versions_yaml" ]]; then
            echo "versions:"
            echo -n "$versions_yaml"
        fi
        echo "---"
    } > "$PACKAGES_DIR/${name}.md"

    echo "done"
done < "$INDEX_FILE"