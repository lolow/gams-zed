# TODO — gams-zed

Milestones run top-to-bottom. Don't start a milestone until the previous one's
**Definition of done** ticks pass.

---

## M0 — Reconnaissance ✅ done
- [x] Search GitHub for an existing `tree-sitter-gams` parser.
      → **Found:** `Schlegen/tree-sitter-gams` (Apache-2.0, last push
      2025-12-29). Mostly-complete grammar — see `tests/token-spec.md` §0.
      **Decision:** fork it instead of writing from scratch.
- [x] Read `../gams/syntaxes/Gams.tmLanguage` (plist) end-to-end and list
      every pattern + scope.
- [x] Read `../vscode-gams/syntaxes/gams_org.tmGrammar.json` end-to-end; diff
      against the above and merge into `tests/token-spec.md`.
- [x] Cross-check against the
      [GAMS Dollar Control Options docs](https://www.gams.com/latest/docs/UG_DollarControlOptions.html);
      all 9 official categories present in §5 of the spec (embedded code
      added as polish-tier).

**Definition of done — met:** `tests/token-spec.md` enumerates every token
class with examples and an in-scope/polish/deferred marker.

### M0 outcome — the gap list
The Schlegen parser must be patched in M1 to close these spec items before it
is usable for Zed highlighting:
- §1.1–§1.3 — comments (currently `#`-prefixed; **blocker**)
- §3.4–§3.6 — `INF`, `NA`, `EPS` literals
- §4 — `%macro%` references
- §5 — `$`-control directives
- §6.4 — `table` declaration
- §7 — equation definition syntax (`..`, `=e=/=l=/=g=/=n=/=x=`)
- §8.4 — model-type literals
- §11.2 — equation suffixes (`.range`, `.slack*`, `.infeas`)
- §12.6 / §12.10 — set-element `.` and `*` range expansion

---

## M1 — Fork & patch `tree-sitter-gams` (sibling repo `../tree-sitter-gams/`)
Strategy: fork `Schlegen/tree-sitter-gams` to keep its working core (sets,
parameters, scalars, variables, equations declarations, models, solve,
display, loops, if/elseif, indexed operators, built-ins, assignments,
attribute references). Apache-2.0 → just retain `LICENSE` + add NOTICE.

- [ ] Fork the repo, clone next to `gams-zed/` as `../tree-sitter-gams/`.
- [ ] **Replace** the `comment` rule with three rules:
  - `line_comment`: `^\*[^\n]*` (column-1 only — use external scanner since
    Tree-sitter's `extras` can't easily express column-1).
  - `block_comment`: case-insensitive `(^\$|\$\$)ontext … (^\$|\$\$)offtext`.
  - `block_comment_c`: `/\*…\*/`.
  - Wire all three into `extras`; remove the broken `#` rule.
- [ ] Add `dollar_directive`: `$\$?[A-Za-z][A-Za-z_0-9]*` token, with a
      curated `directive_keyword` lookup for highlight selection (per §5).
- [ ] Add `macro_ref`: `%[A-Za-z_][A-Za-z_0-9]*%` and `%\d+%` (numeric arg).
- [ ] Add `table_declaration` (§6.4) — declaration form, table data block
      defer to §15 / TODO entry already in upstream `Todo.md`.
- [ ] Add `equation_definition` (§7) with all relational ops `=e=/=l=/=g=/=n=/=x=`
      (and `=c=/=b=` as polish).
- [ ] Add `model_type` (§8.4) — recognised as a keyword inside `solve`.
- [ ] Extend `variable_attribute_keyword` (S calls it that) with the equation
      suffixes from §11.2 (`range`, `slack`, `slackup`, `slacklo`, `infeas`).
- [ ] Add `INF`, `NA`, `EPS` to `bool` (rename to `literal_constant`).
- [ ] Add range expansion `*` between two set-element identifiers / numbers
      (already partly there in S — verify with `t1*t10`).
- [ ] Add `option`/`abort`/`acronym` statements (upstream Todo lists these too).
- [ ] Run `npx tree-sitter generate` cleanly.
- [ ] `npx tree-sitter test` — corpus passes (see Tests below).

### Tests for M1 (Tree-sitter corpus)
Upstream `Schlegen/tree-sitter-gams/test/*.gms` files use `#`-prefixed comments
(matching the broken comment rule). After the comment-rule rewrite, **regenerate**
those fixtures with real GAMS comments, then add corpus tests under
`../tree-sitter-gams/test/corpus/*.txt`. Each file is a list of
`==== name ====` blocks with input followed by `---` and the expected sexp tree.
Cover at minimum:
- [ ] `comments.txt` — column-1 `*`, `$ontext` block, `/* */`, mixed.
- [ ] `strings.txt` — single, double, with `%macro%`, with escaped quotes.
- [ ] `declarations.txt` — set, parameter, scalar, table, variable, equation,
      model, alias; with and without descriptions and assignments.
- [ ] `equations.txt` — `=e=` `=l=` `=g=` `=n=` definitions; multi-line.
- [ ] `solve.txt` — LP, NLP, MIP, MCP variants.
- [ ] `control_flow.txt` — `if/elseif/else`, `loop`, `while`, `for`.
- [ ] `dollar_directives.txt` — `$include`, `$set`, `$ifthen … $endif`,
      `$gdxin … $loaddc … $gdxout`.
- [ ] `suffixes.txt` — `x.l(i,j)`, `x.up`, `x.fx`, etc.
- [ ] `numbers.txt` — int, float, scientific, `INF`, `NA`, `EPS`.
- [ ] `error_recovery.txt` — unterminated string, missing `;`, dangling
      `$ontext` (parser must produce an `ERROR` node, not panic).

**Definition of done:** all corpus tests pass; `tree-sitter parse fixtures/*.gms`
on real-world `../gams/` and `../vscode-gams/` sample files emits zero ERROR
nodes outside `error_recovery.txt`.

---

## M2 — Zed extension scaffold (`gams-zed/`)
- [ ] `extension.toml` with `id = "gams"`, `name = "GAMS"`, `version = "0.1.0"`,
      `[grammars.gams]` block pointing to `tree-sitter-gams` git URL + commit.
- [ ] `languages/gams/config.toml`:
  - `name = "GAMS"`
  - `grammar = "gams"`
  - `path_suffixes = ["gms", "inc", "lst"]` (decide on `.gdx` — likely no,
    it's binary)
  - `line_comments = ["* "]` (note: column-1 only — Zed's prefix-style is the
    closest fit; document the limitation)
  - `autoclose_before` and brackets matching `language-configuration.json`
    from both source extensions, reconciled.
- [ ] `languages/gams/highlights.scm` — map every token-spec entry to a
      Zed highlight scope.
- [ ] `languages/gams/brackets.scm` — `()`, `[]`, `{}`, plus `'…'` / `"…"`.
- [ ] `languages/gams/indents.scm` — indent after `loop(`, `if(`, `(` in
      declarations; dedent on matching `)` and `;`.
- [ ] `languages/gams/outline.scm` — surface `set`, `parameter`, `scalar`,
      `variable`, `equation`, `model`, `solve` declarations.
- [ ] `languages/gams/injections.scm` — embed `%macro%` as a `constant`
      injection inside strings (optional polish).
- [ ] `LICENSE` (match the upstream license pattern; both sources use MIT-like).
- [ ] `README.md` — install via `zed: install dev extension`, screenshot.

**Definition of done:** `zed: install dev extension` succeeds with no manifest
errors and the extension appears under `zed: extensions`.

---

## M3 — Sample fixtures + visual verification
- [ ] `tests/samples/hello.gms` — minimal model.
- [ ] `tests/samples/transport.gms` — the canonical GAMS transport example
      (covers sets, parameters, tables, variables, equations, solve).
- [ ] `tests/samples/dollar_directives.gms` — exercises `$include`,
      `$set`, `$ifthen`, macros, comments.
- [ ] `tests/samples/edge_cases.inc` — column-1 `*`, `/* */`, `$ontext` blocks,
      multiline strings.
- [ ] `tests/README.md` — for each sample list expected highlight result per
      token (e.g. "line 7 `SETS` → keyword, line 8 `i` → type"). Reviewer
      compares Zed rendering against the list.

**Definition of done:** all samples open in Zed with the expected highlights;
no token shows up as "unhighlighted plaintext" except where token-spec marks
it as deferred.

---

## M4 — Polish & release
- [ ] `CHANGELOG.md` initial entry.
- [ ] Pin `tree-sitter-gams` to a tagged release commit in `extension.toml`.
- [ ] Open PR to `zed-industries/extensions` registry once stable.
- [ ] Add GitHub Actions CI for the parser repo (`tree-sitter test`).
- [ ] Document the upgrade path from the two VSCode extensions in `README.md`.

---

## Deferred (post-1.0)
- LSP server integration (`gams-lsp` if/when one exists).
- Run/Listing/GDX commands from `vscode-gams` — would need a Rust extension
  crate using `zed-extension-api`.
- Snippets — Zed snippet support evolves; revisit when the API stabilizes.
- `.lst` listing-file specific highlighting (errors, solve summary tables).
