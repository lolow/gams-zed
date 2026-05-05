# Changelog

## 0.1.0 — 2026-05-05

First public release. Syntax highlighting, bracket matching,
indentation, and a symbol outline for GAMS source files in the
[Zed editor](https://zed.dev).

### Files
- `extension.toml` pinned to `tree-sitter-gams v0.1.0`.
- `languages/gams/config.toml` — `.gms`/`.inc`/`.lst` file types,
  column-1 `*` line comments, full bracket pairs, `$`/`%` as word
  characters.
- `languages/gams/highlights.scm` — 21 distinct capture types covering
  comments, strings, numbers, macros, declaration keywords, statement
  keywords, operators, suffix attributes, model types, literal
  constants, and punctuation.
- `languages/gams/brackets.scm`, `indents.scm`, `outline.scm` —
  parens + slash-fenced data blocks, indentation rules, and a
  declaration-name outline.
- `languages/gams/injections.scm` — placeholder.

### Coverage
The four sample fixtures under `tests/samples/` (`hello.gms`,
`transport.gms`, `dollar_directives.gms`, `edge_cases.inc`) parse with
**zero ERROR nodes** and together fire all 21 distinct captures.

### Known limitations
- The `option`, `abort`, `if`/`elseif`/`else` introducer keywords are
  not directly highlightable because the parser produces them as
  anonymous regex tokens. Promotion to named keyword rules is a
  follow-up parser change.
- `%macro%` references inside double-quoted strings are coloured as
  string content, not as macros — string injection is deferred until
  the parser splits the string rule into open/content/close tokens.
- `[`, `]`, `{`, `}`, `"`, `'`, `%` are autoclosed via `config.toml`
  but not part of the parse tree, so bracket-jumping for those falls
  back to Zed's text-level pairing.
- The grammar lives in a sibling repository pinned via a `file://`
  URL. Installing on another machine requires updating
  `[grammars.gams].repository` to point at your local clone (or to a
  public git remote once the fork is published).
