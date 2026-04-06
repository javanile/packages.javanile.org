---
name: myown
title: myown
description: "(no description)"
github: https://github.com/francescobianco/myown
repository: https://github.com/francescobianco/myown
author_github: francescobianco
readme: https://raw.githubusercontent.com/francescobianco/myown/main/README.md
versions:
  - main
  - 0.1.0
---

# 📂 myown

**myown** is a simple yet powerful shell script that ensures you can always keep working on your projects without permission headaches. It aligns the ownership of files and directories to your current user, supporting both regular and recursive operations.

## The Story

Have you ever been in the middle of debugging a complex project, only to find yourself stuck because some files were mysteriously created with the wrong permissions? 

It’s a common issue when working with tools like **Docker**. Those containers that build your code or process your data leave behind files and directories owned by `root` or some other user. Suddenly, your editor complains, your commands fail, and you’re left battling with `chown` or `sudo` instead of focusing on your code.

It’s frustrating. It’s boring. And it disrupts your flow. 

**myown** is here to save the day. With a single command, you can fix all those permission issues instantly. Forget the frustration and get back to coding and debugging without breaking a sweat.

## Features

- Changes the ownership of files and directories to match your current user.
- Supports recursive updates with the `-r` flag.
- Automatically uses `sudo` if needed, so you don’t have to worry about permissions.
- Provides clear messages for every operation, including success, errors, or missing files.

## Installation

To install **myown**, follow these simple steps:

1. Download the script:
   ```bash
   curl -o myown https://raw.githubusercontent.com/francescobianco/myown/refs/heads/main/bin/myown
   ```

2. Copy the script to `/usr/local/bin`:
   ```bash
   sudo mv myown /usr/local/bin
   ```

3. Make it executable:
   ```bash
   sudo chmod +x /usr/local/bin/myown
   ```

Now you can run `myown` from anywhere on your system.

## Usage

```bash
myown [-r] file1 [file2 ...]
```

### Options
- **`-r`**: Apply changes recursively to directories and their contents.

### Arguments
- **`file1 file2 ...`**: A list of files or directories to adjust.

## Examples

Fix ownership of a single file:
```bash
myown file.txt
```

Fix ownership of a directory and its contents:
```bash
myown -r myfolder
```

Fix ownership of multiple files and directories:
```bash
myown file1.txt file2.txt myfolder
```

## How It Works

1. The script reads the owner and group of your home directory (`$HOME`) to determine the default ownership.
2. It processes the provided files and directories:
    - Applies `chown` to set the correct ownership.
    - Automatically invokes `sudo` if elevated privileges are required.
3. For each file or directory, it provides feedback:
    - Success messages for updated permissions.
    - Warnings for non-existent files or directories.
    - Error messages if something goes wrong.

## Why Use MyOwn?

When you’re deep into debugging or developing, permission issues can derail your workflow. **myown** was designed to quickly fix these problems, so you can focus on what truly matters: your code.

This script is particularly useful in Docker-based workflows, where files created by containers often have mismatched permissions. Instead of losing precious time troubleshooting, just run `myown` to seamlessly realign your project’s file ownership and get back to work.

## Requirements

- A Unix/Linux environment with support for `chown`.
- `sudo` privileges for modifying files you don’t own.

## Note

Be cautious when using the `-r` flag on large directories to avoid unintended changes.

## Author

Created out of necessity by a developer frustrated with permission issues in modern workflows, **myown** is here to make your life easier. Give it a try, and never let permission problems interrupt your development again.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
