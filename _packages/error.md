---
name: error
title: error
description: "Prints error messages to stderr, optionally exiting with a status code"
github: https://github.com/francescobianco/error.git
repository: https://github.com/francescobianco/error
author_github: francescobianco
readme: https://raw.githubusercontent.com/francescobianco/error/main/README.md
versions:
  - main
---

# 🚨 error

**error** is a simple Mush module that prints error messages to `stderr`, optionally exiting with a status code — Mush-style!

## 💾 Installation

To use **error**, add it as a dependency in your `Manifest.toml`:

```toml
[dependencies]
error = "*"
```

## ⚙️ Usage

Using **error** is extremely easy. Just follow these steps:

1. Import the module into your Mush project.
2. Call the `error` function to print messages to `stderr`, with optional exit.

### Shell Examples

```shell
# print error to stderr, no exit
$ error "file not found"
error: file not found

# print error to stderr and exit with status code
$ error "syntax error" 1
error: syntax error
```

### In a Mush script

```mush
extern package error

main() {
    error "something went wrong" 2
}
```

## 🪪 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
