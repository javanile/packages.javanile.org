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

    # extract subpath from index line (3rd field if it starts with "packages/")
    subpath=$(echo "$line" | awk '{if ($3 ~ /^packages\//) print $3}')

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

    # build repository URL (strip .git, append tree/main/subpath if present)
    repo_base="${github%.git}"
    if [[ -n "$subpath" ]]; then
        repository="${repo_base}/tree/main/${subpath}"
    else
        repository="${repo_base}"
    fi

    # extract author from GitHub URL (segment after github.com/)
    author_github=$(echo "$repo_base" | sed 's|https://github.com/||' | cut -d'/' -f1)

    # build raw README URL
    raw_base=$(echo "$repo_base" | sed 's|https://github.com/|https://raw.githubusercontent.com/|')
    if [[ -n "$subpath" ]]; then
        readme_url="${raw_base}/main/${subpath}/README.md"
    else
        readme_url="${raw_base}/main/README.md"
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
        echo "repository: ${repository}"
        echo "author_github: ${author_github}"
        echo "readme: ${readme_url}"
        [[ -n "$path" ]] && echo "path: ${path}"
        [[ -n "$subpath" ]] && echo "subpath: ${subpath}"
        if [[ -n "$versions_yaml" ]]; then
            echo "versions:"
            echo -n "$versions_yaml"
        fi
        echo "---"
        echo ""
        curl -fsSL "${readme_url}" 2>/dev/null || true
    } > "$PACKAGES_DIR/${name}.md"

    echo "done"
done < "$INDEX_FILE"