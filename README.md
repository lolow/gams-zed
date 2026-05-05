# gams-zed

[Zed editor](https://zed.dev) extension for the
[GAMS](https://www.gams.com/) (General Algebraic Modeling System) language.

Provides syntax highlighting, bracket matching, indentation guides, and a
symbol outline for `.gms`, `.inc`, and `.lst` files.

## Status

Pre-release (`0.1.0`). Syntax highlighting works on the full Schlegen
[tree-sitter-gams][upstream-parser] coverage plus our local fork's additions:

- Column-1 `*` line comments, `$ontext`/`$offtext` block comments,
  `/* … */` C-style block comments
- `$include`, `$set`, `$ifThen`, `$gdxIn` and other dollar directives
- `%macro%` references
- Equation definitions with `=e=/=l=/=g=/=n=/=x=/=c=/=b=`
- Table declarations
- `option`, `abort`, `acronym` statements
- `.l`, `.lo`, `.up`, `.fx`, `.scale`, `.range`, `.slack`, `.infeas`
  attribute suffixes
- All 15 GAMS solver model types (`lp`/`nlp`/`mip`/`mcp`/`emp`/…)
- `inf`, `na`, `eps` literal constants

See `tests/token-spec.md` for the full coverage matrix.

## Install (development)

`gams-zed` is not yet published to the Zed extension registry.

1. Clone this repository **and** the parser fork side-by-side:
   ```sh
   git clone https://github.com/lolow/gams-zed.git
   git clone https://github.com/lolow/tree-sitter-gams.git
   ```
2. Open `extension.toml` and update `[grammars.gams].repository` to point
   at your local `tree-sitter-gams/` clone:
   ```toml
   repository = "file:///absolute/path/to/tree-sitter-gams"
   ```
   (The repository ships with an example absolute path that you'll need
   to change for your machine.)
3. In Zed, run the command palette action **`zed: install dev extension`**
   and select the `gams-zed/` directory. Zed will fetch the grammar from
   the `file://` URL, compile it, and register the language.
4. Open any `.gms` file. Highlighting should activate automatically; if
   not, run **`editor: select language`** and pick **GAMS**.

After editing the grammar or the `.scm` query files, run **`zed: reload
extensions`** to pick up changes.

## Project layout

```
gams-zed/
├── extension.toml              # manifest: id, name, version, grammar source
├── languages/
│   └── gams/
│       ├── config.toml         # name, grammar, suffixes, comments, brackets
│       ├── highlights.scm      # syntax-colour queries
│       ├── brackets.scm        # bracket-match pairs
│       ├── indents.scm         # auto-indent rules
│       ├── outline.scm         # symbol outline
│       └── injections.scm      # (placeholder)
├── tests/
│   └── token-spec.md           # canonical GAMS token catalogue
├── CLAUDE.md                   # AI-assistant project notes
├── TODO.md                     # roadmap
├── LICENSE                     # Apache-2.0
└── README.md                   # this file
```

The grammar lives in a sibling repository (`../tree-sitter-gams/`),
forked from [Schlegen/tree-sitter-gams][upstream-parser] (Apache-2.0).
See that repository's `NOTICE` for upstream attribution and `git log`
for the divergence list.

## Reference VSCode extensions

Two TextMate-grammar VSCode extensions inspired the token catalogue and
served as the specification source while the parser was being patched:

- [`lolow/gams`](https://github.com/lolow/gams) — minimal `.tmLanguage`
  grammar
- [`eunseong-park/vscode-gams`](https://github.com/eunseong-park/vscode-gams)
  — feature-rich extension with run / listing / GDX commands

## Upgrading from the VSCode extensions

If you used either VSCode extension before, this is what carries over
and what doesn't:

| Feature | `lolow/gams` | `eunseong-park/vscode-gams` | `gams-zed` |
|---|---|---|---|
| Column-1 `*` line comments | ✅ | ✅ | ✅ |
| `$ontext`/`$offtext` block | ✅ | ✅ | ✅ |
| `/* */` block | ✅ | ✅ | ✅ |
| `// `, `!! ` line comments | ✅ | ✅ | ❌ (require `$eolcom`-state tracking) |
| `%macro%` highlighting | ✅ | ✅ | ✅ outside strings; ❌ inside strings |
| Dollar directives | curated list | extensive list | ✅ — every `$<name>` line is a single `@keyword.directive` token |
| `=e=/=l=/=g=/=x=` operators | ✅ | ✅ | ✅ + adds `=n=`, `=c=`, `=b=` |
| Solver model types (`lp/nlp/…`) | ❌ | ✅ | ✅ |
| Variable suffixes (`.l/.lo/.up/.fx/.scale/.m`) | ✅ | ✅ extensive | ✅ + equation suffixes (`.range`, `.slack`, `.infeas`) |
| `MODEL`/`ALIAS`/`ACRONYM`/`FILE` storage type | partial | ✅ | ✅ |
| `INF`/`NA`/`EPS` numeric sentinels | ✅ | ✅ | ✅ |
| Symbol outline | ❌ | partial | ✅ — sets, parameters, scalars, tables, variables, equations (decl + def), models, alias/acronym, solve |
| Run GAMS / open listing / GDX | ❌ | ✅ | ❌ — would need a Zed extension API + Rust/WASM crate; deferred post-1.0 |
| `.lst` listing-file syntax | ❌ | partial | ❌ — deferred post-1.0 |
| MPSGE bridge directives | ❌ | partial | ❌ — deferred (highlighted as generic `@keyword.directive`) |
| Embedded code (`$onEmbeddedCode python: …`) | ❌ | partial | ❌ — body falls inside `dollar_directive` lines, not injected |

In short: the **highlighting** part of `vscode-gams` is at parity or
better; the **run / build / listing-file** integration is intentionally
out of scope for this release.

## Roadmap

See [`TODO.md`](./TODO.md). Next milestones:

- **M3:** sample fixtures + visual verification
- **M4:** polish, changelog, public registry submission

LSP integration, run/build commands, and `.lst` listing-file specific
highlighting are post-1.0.

## License

Apache-2.0 — see [`LICENSE`](./LICENSE).

[upstream-parser]: https://github.com/Schlegen/tree-sitter-gams
