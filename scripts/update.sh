#!/bin/bash

INDEX_FILE=".mush/registry/index/github-javanile-mush.index"
PACKAGES_DIR="_packages"

mkdir -p "$PACKAGES_DIR"

while IFS= read -r line || [[ -n "$line" ]]; do
    # skip empty lines and comment-only lines
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # extract package name (first field)
    name=$(echo "$line" | awk '{print $1}')

    # extract github url (second field)
    github=$(echo "$line" | awk '{print $2}')

    # extract description: everything after the last '#'
    if [[ "$line" == *"#"* ]]; then
        description=$(echo "$line" | sed 's/.*#[[:space:]]*//')
        # normalize "(no description)" to empty
        [[ "$description" == "(no description)" ]] && description=""
    else
        description=""
    fi

    cat > "$PACKAGES_DIR/${name}.md" <<EOF
---
name: ${name}
description: "${description}"
github: ${github}
---
EOF

    echo "Updated: ${name}"
done < "$INDEX_FILE"