# gams-zed — Claude project notes

## Goal
Provide GAMS (General Algebraic Modeling System) syntax support for the
[Zed editor](https://zed.dev) at `gams-zed/`, ported from the two reference
VSCode extensions in sibling directories:

- `../gams/` — minimal extension by `lolow` (TextMate plist grammar `Gams.tmLanguage`,
  scope `source.gms`, file types `.gms`, `.inc`).
- `../vscode-gams/` — feature-rich extension by `eunseong-park` (JSON TextMate grammar
  `gams_org.tmGrammar.json`, scope `source.gams`, file types `.gms`, `.inc`, `.lst`, `.gdx`,
  plus run/listing/GDX commands written in TypeScript under `src/`).

Only **syntax highlighting + language configuration** is in scope for the first
release. Run/build/IDE integration features from `vscode-gams` are out of scope
unless promoted later via a Zed extension API + WASM crate.

## Important: Zed is not VSCode
Zed extensions do NOT consume TextMate (`.tmLanguage` / `tmGrammar.json`) grammars.
Highlighting in Zed is driven by **Tree-sitter** parsers and `.scm` query files.

This means we cannot copy the grammars directly. **M0 chose path:** fork the
existing [`Schlegen/tree-sitter-gams`](https://github.com/Schlegen/tree-sitter-gams)
(Apache-2.0, last push 2025-12-29) into a sibling repo `../tree-sitter-gams/`.
That parser already covers ~70 % of GAMS (sets, parameters, scalars, variables,
equation declarations, models, solve, display, loops, if/elseif, indexed
operators, built-ins, assignments, suffix references). The fork must close
specific gaps before it's usable for Zed highlighting — see
`tests/token-spec.md` and `TODO.md#M1` for the full list. The two TextMate
grammars in `../gams/syntaxes/` and `../vscode-gams/syntaxes/` remain the
**spec source of truth** for everything not yet in the parser.

## Target layout
```
gams-zed/
├── extension.toml                    # Zed manifest (id, name, grammars, languages)
├── languages/
│   └── gams/
│       ├── config.toml               # name, path_suffixes, line_comments, brackets…
│       ├── highlights.scm            # token → highlight scope mapping
│       ├── brackets.scm              # bracket pairs for matching/auto-close
│       ├── indents.scm               # indentation rules
│       ├── outline.scm               # symbol outline
│       └── injections.scm            # optional (e.g. embed comments, %macros%)
├── tests/
│   ├── samples/                      # .gms / .inc fixtures
│   └── README.md                     # how to load + visually verify in Zed dev mode
├── TODO.md
├── CLAUDE.md  ← this file
├── LICENSE
└── README.md
```
A separate repo `tree-sitter-gams/` (sibling, not nested) will hold the parser
and is referenced from `extension.toml` by git URL + commit SHA.

## GAMS lexical facts to encode
Distilled from the two reference grammars and `language-configuration.json` files:

| Aspect | Rule |
| --- | --- |
| Line comment | `*` **only when in column 1** (GAMS convention) |
| Block comment (dollar) | `$ontext` … `$offtext` and `$$ontext` … `$$offtext`, case-insensitive |
| Block comment (C-style) | `/* … */` (supported by `vscode-gams`) |
| Strings | `'…'` and `"…"`; `%name%` macros are highlightable inside strings |
| Macros | `%identifier%` → `entity.name.class` / `@constant` |
| Dollar directives | `$include`, `$set`, `$setglobal`, `$if`, `$ifthen`, `$call`, `$gdxin`, … |
| Declaration keywords | `SET(S)`, `PARAMETER(S)`, `SCALAR(S)`, `TABLE`, `VARIABLE(S)` (`POSITIVE`, `NEGATIVE`, `BINARY`, `INTEGER`, `FREE`), `EQUATION(S)`, `MODEL(S)`, `ALIAS` |
| Control flow | `IF`/`ELSEIF`/`ELSE`, `WHILE`, `LOOP`, `FOR`, `REPEAT`, `UNTIL`, `BREAK`, `CONTINUE` |
| Solve | `SOLVE … USING … MINIMIZING/MAXIMIZING …` |
| Suffixes | `.l`, `.lo`, `.up`, `.m`, `.fx`, `.scale`, `.prior`, `.stage` |
| Math funcs | `abs`, `arctan`, `ceil`, `cos`, `exp`, `floor`, `log`, `log10`, `max`, `min`, `mod`, `power`, `round`, `sign`, `sin`, `sqr`, `sqrt`, `sum`, `prod`, `smin`, `smax`, … |
| Operators | `=e=`, `=l=`, `=g=`, `=n=`, `=x=`, `=c=`, `=b=`, `..`, `**`, `=`, arithmetic |
| Identifiers | case-insensitive, `[A-Za-z][A-Za-z0-9_]*`; `$` legal in dollar directives only |
| File extensions | `.gms`, `.inc`, `.lst`, `.gdx` (treat `.lst`/`.gdx` as read-only/output if helpful) |

## Build & test workflow
- **Tree-sitter parser:** `npm install && npx tree-sitter generate && npx tree-sitter test`
  inside `tree-sitter-gams/`. Corpus tests under `tree-sitter-gams/test/corpus/`.
- **Zed dev install:** in Zed, run `zed: install dev extension` and pick the
  `gams-zed/` directory. Reload with `zed: reload extensions` after edits.
- **Manual visual check:** open `tests/samples/*.gms` in Zed and confirm the
  expected highlight scopes (see `tests/README.md`).
- **CI (later):** GitHub Actions running `tree-sitter test` on the parser
  repo + `cargo test` if a Rust extension crate is added.

## Conventions for this project
- All `.scm` capture names follow [Zed's standard highlight set]
  (`@keyword`, `@type`, `@function`, `@variable`, `@string`, `@number`,
  `@comment`, `@operator`, `@punctuation.bracket`, `@constant`, `@attribute`).
- GAMS is case-insensitive — keyword regexes in the parser must be
  case-insensitive (`/SET/i`) and `highlights.scm` should match the
  canonical lowercase form emitted by the parser.
- Don't hand-edit `parser.c`; regenerate with `tree-sitter generate`.
- Keep `extension.toml` `version` in sync with git tags (semver).

## References
- Zed extension docs: <https://zed.dev/docs/extensions>
- Zed language extensions: <https://zed.dev/docs/extensions/languages>
- Tree-sitter authoring: <https://tree-sitter.github.io/tree-sitter/creating-parsers>
- Existing Zed language extensions (good templates): the `extensions/` tree of
  the `zed-industries/zed` repo, e.g. `gleam`, `toml`, `lua`.
