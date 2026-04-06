#!/bin/bash

INDEX_FILE=".mush/registry/index/github-javanile-mush.index"
CATEGORIES_MAP="categories.map"
PACKAGES_DIR="_packages"
CACHE_DIR=".packages_cache"

mkdir -p "$PACKAGES_DIR"
mkdir -p "$CACHE_DIR"

# load categories map: associative array category -> keywords
declare -A CATEGORY_KEYWORDS
while IFS= read -r mapline || [[ -n "$mapline" ]]; do
    [[ -z "$mapline" || "$mapline" =~ ^[[:space:]]*# ]] && continue
    cat_name=$(echo "$mapline" | cut -d: -f1 | tr -d '[:space:]')
    cat_keywords=$(echo "$mapline" | cut -d: -f2-)
    [[ -n "$cat_name" ]] && CATEGORY_KEYWORDS["$cat_name"]="$cat_keywords"
done < "$CATEGORIES_MAP"

# match a package name+description against categories, return space-separated list
match_categories() {
    local pkg_name="$1"
    local pkg_desc="$2"
    local haystack
    haystack=$(echo "${pkg_name} ${pkg_desc}" | tr '[:upper:]' '[:lower:]')
    local matched=()
    for cat in "${!CATEGORY_KEYWORDS[@]}"; do
        for kw in ${CATEGORY_KEYWORDS[$cat]}; do
            if [[ "$haystack" == *"$kw"* ]]; then
                matched+=("$cat")
                break
            fi
        done
    done
    echo "${matched[@]}"
}

while IFS= read -r line || [[ -n "$line" ]]; do
    # skip empty lines and comment-only lines
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # extract package name (first field)
    name=$(echo "$line" | awk '{print $1}')

    echo -n "Processing: ${name} ... "

    mkdir -p "${CACHE_DIR}/${name}"

    # run mush info with cache
    info_cache="${CACHE_DIR}/${name}/info.txt"
    if [[ -f "$info_cache" ]]; then
        info=$(cat "$info_cache")
    else
        info=$(MUSH_HOME=$PWD/.mush mush info "$name" 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
        echo "$info" > "$info_cache"
    fi

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

    # match categories from categories.map
    matched_cats=$(match_categories "$name" "$description")

    # build YAML categories array
    categories_yaml=""
    for cat in $matched_cats; do
        categories_yaml="${categories_yaml}  - ${cat}"$'\n'
    done

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
        echo "title: ${name}"
        echo "description: \"${description}\""
        echo "github: ${github}"
        echo "repository: ${repository}"
        echo "author_github: ${author_github}"
        echo "readme: ${readme_url}"
        [[ -n "$path" ]] && echo "path: ${path}"
        [[ -n "$subpath" ]] && echo "subpath: ${subpath}"
        if [[ -n "$categories_yaml" ]]; then
            echo "categories:"
            echo -n "$categories_yaml"
        fi
        if [[ -n "$versions_yaml" ]]; then
            echo "versions:"
            echo -n "$versions_yaml"
        fi
        echo "---"
        echo ""
        # fetch README with cache
        readme_cache="${CACHE_DIR}/${name}/README.md"
        if [[ -f "$readme_cache" ]]; then
            cat "$readme_cache"
        else
            readme_content=$(curl -fsSL "${readme_url}" 2>/dev/null || true)
            echo "$readme_content" > "$readme_cache"
            echo "$readme_content"
        fi
    } > "$PACKAGES_DIR/${name}.md"

    echo "done"
done < "$INDEX_FILE"