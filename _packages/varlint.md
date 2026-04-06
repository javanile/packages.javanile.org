---
name: varlint
title: varlint
description: "(no description)"
github: https://github.com/francescobianco/varlint.git
repository: https://github.com/francescobianco/varlint
author_github: francescobianco
readme: https://raw.githubusercontent.com/francescobianco/varlint/main/README.md
versions:
  - main
---

# varlint

A static analysis tool for Bash that enforces **variable discipline** and **function purity contracts**.

varlint is opinionated: it doesn't just warn about risky patterns — it enforces architectural constraints. Inside a function, every variable must be explicitly declared `local`. Every side effect must be intentional.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/francescobianco/varlint/main/bin/varlint -o /usr/local/bin/varlint
chmod +x /usr/local/bin/varlint
```

Or without root:

```bash
curl -fsSL https://raw.githubusercontent.com/francescobianco/varlint/main/bin/varlint -o ~/.local/bin/varlint
chmod +x ~/.local/bin/varlint
```

## Usage

```bash
varlint [OPTIONS] <file>...
```

## Options

| Flag | Description |
|------|-------------|
| `--strict` | `GLOBAL_READ` and `SIDE_EFFECT_BUILTIN` become errors |
| `--enforce-pure` | All functions treated as `@varlint pure` |
| `--only <codes>` | Show only violations matching these codes (comma-separated) |
| `--fail-on <rules>` | Exit 1 if any of these rules fire (comma-separated) |
| `--no-color` | Disable colored output |

```bash
varlint script.sh
varlint --strict lib/*.sh
varlint --only VL07 script.sh
varlint --only VL01,VL02 lib/*.sh
varlint --fail-on GLOBAL_WRITE,DYNAMIC_EVAL script.sh
```

## Glob patterns

varlint expands glob patterns internally with full `**` recursive support. Quote the pattern so the shell does not expand it first:

```bash
varlint '**/*.sh'
varlint './**/*.sh' --strict
varlint 'src/**/*.sh' --only VL01,VL07
```

Without quotes, the shell expands the pattern before varlint sees it. Without `globstar` enabled in your shell, `**` only goes one level deep and subdirectories are missed. Quoting passes the pattern to varlint intact, which always expands it recursively regardless of your shell settings.

If you prefer unquoted globs, enable `globstar` in your shell first:

```bash
shopt -s globstar
varlint ./**/*.sh
```

## Rules

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| `VL01` | `GLOBAL_WRITE` | error | Assignment to a variable not declared `local` |
| `VL02` | `GLOBAL_READ` | warning | Reading a variable not in local scope |
| `VL03` | `DYNAMIC_EVAL` | error | `eval` prevents static analysis |
| `VL04` | `INDIRECT_EXPANSION` | error | `${!var}` is not statically resolvable |
| `VL05` | `DYNAMIC_SOURCE` | error | `source "$file"` with a variable path |
| `VL06` | `SIDE_EFFECT_BUILTIN` | warning | `cd`, `export`, `read` modify external state |
| `VL07` | `LOCAL_SPLIT` | warning | `local` declaration with inline value — declare and assign on separate lines |

## Output

```
script.sh:12 => Error: [VL01] variable 'x' assigned without local in 'foo'
script.sh:14 => Warning: [VL02] variable '$name' read from global scope in 'foo'
summary: 1 error(s), 1 warning(s)
```

## Variable scope

`local` declares scope. Assignment happens on the next line. Always.

```bash
# correct
process() {
  local result
  local name
  result=$(compute)
  name="$1"
  echo "$result $name"
}

# smell — VL07
process() {
  local result=$(compute)   # inline value
  local name="$1"           # inline value
  echo "$result $name"
}
```

Exception: `local -r` (readonly) may assign inline since the value cannot be changed later.

## Annotations

**`@varlint pure`** — enforce full purity (GLOBAL_READ and SIDE_EFFECT_BUILTIN become errors)

```bash
# @varlint pure
add() {
  local a
  local b
  a="$1"
  b="$2"
  echo $((a + b))
}
```

**`@varlint allow=RULE,...`** — suppress specific rules for a function

```bash
# @varlint allow=GLOBAL_READ,DYNAMIC_EVAL
legacy_fn() {
  eval "$cmd"
  echo "$GLOBAL"
}
```

**`@varlint impure`** — suppress all violations for a function

```bash
# @varlint impure
compat_fn() {
  eval "$cmd"
  cd /tmp
}
```

## Ignore mechanisms

Disable a single line:

```bash
RESULT=42  # varlint disable-line=GLOBAL_WRITE
```

Disable a block:

```bash
# varlint disable=GLOBAL_WRITE,DYNAMIC_EVAL
legacy_block() {
  x=1
  eval "$cmd"
}
# varlint enable
```

## Strict mode

```bash
varlint --strict script.sh
```

Promotes warnings to errors: `VL02 GLOBAL_READ` and `VL06 SIDE_EFFECT_BUILTIN`.

## Limitations

varlint is a lightweight line-by-line parser, not a full Bash AST.

- Single-line functions (`foo() { :; }`) are not analyzed
- Brace counting can be confused by `{` inside strings or heredocs
- `eval` content is never analyzed

Use `# @varlint impure` or `# varlint disable` to acknowledge these cases explicitly.

## Running tests

```bash
bash tests/test_rules.sh
```
