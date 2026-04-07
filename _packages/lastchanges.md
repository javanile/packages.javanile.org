---
name: lastchanges
title: lastchanges
description: "Lists the most recently modified files in the system"
github: https://github.com/francescobianco/lastchanges
repository: https://github.com/francescobianco/lastchanges
author_github: francescobianco
readme: https://raw.githubusercontent.com/francescobianco/lastchanges/main/README.md
categories:
  - git
  - system
versions:
  - main
  - 0.1.0
---

# lastchanges

> lastchanges (recommended to be abbreviated as lc) lists the most recently modified files in the system, helping you track changes quickly.

## Installation

Install [Mush](https://mush.javanile.org/) by Javanile

```bash
curl get.javanile.org/mush | bash -
```

Install `lastchanges` utility:

```bash
mush install lastchanges
```

Run to analyzie filesystem

```bash
lastchanges /
```

## Usage on Android device

Download the script 

```
am start -a android.intent.action.VIEW -d "https://github.com/francescobianco/lastchanges/releases/download/0.1.0/lastchanges"
```

Run the script to explore the `Download/` directory

```
sh /sdcard/Download/lastchanges /sdcard/Download/
```
