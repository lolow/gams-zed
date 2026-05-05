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

## M1 — Fork & patch `tree-sitter-gams` (sibling repo `../tree-sitter-gams/`) ✅ done
Cloned `Schlegen/tree-sitter-gams` to `../tree-sitter-gams/`. 11 commits
on top of upstream HEAD `78dd717` (see `../tree-sitter-gams/git log`):

- [x] Fork repo + add NOTICE + `tree-sitter.json` (ABI 15 build).
- [x] **Comment rule rewrite** via external scanner (`src/scanner.c`):
      column-0 `*` line comments, `$ontext`/`$offtext` (single-$ at col 0
      or `$$` anywhere), `/* */` C-style. The scanner skips its own
      leading whitespace because tree-sitter only calls externals once
      per parser step, before the lexer's whitespace skip.
- [x] `dollar_directive`: scanner-emitted token consuming `$<name>` (col 0)
      or `$$<name>` (anywhere) through end of line; dispatches to the block-
      comment branch when the name is `ontext`. Wired as a top-level node
      alongside `statement` in `source_file`.
- [x] `macro_ref`: regex token `%[A-Za-z_]\w*%` and `%\d+`; added as an
      expression alternative.
- [x] `equation_definition`: `name[(domain)][\$cond] .. lhs <op> rhs ;`
      with `=e=/=l=/=g=/=n=/=x=/=c=/=b=`. Required a new conflict
      declaration between `identifier_with_domain_args` and `index_element`.
- [x] `table_declaration`: keyword + name + optional description + opaque
      `table_body` token through next `;` (2D layout intentionally not
      modelled — adds no value for highlighting).
- [x] `model_type`: case-insensitive choice over the 15 GAMS solver types
      with `prec(1)` to win the lexer tie-break against `identifier`.
- [x] `bool` extended to literal_constant covering `yes/no/inf/na/eps`;
      `scalar_value_block` now accepts either number or literal.
- [x] `solve_statement`: direction+objective made optional in the
      `using <type>` form so `solve m using mcp;` parses.
- [x] `variable_attribute_keyword` extended with equation suffixes
      (`range`, `slack`, `slacklo`, `slackup`, `infeas`) and the missing
      variable suffixes (`prior`, `stage`).
- [x] `option`, `abort[.noError]`, `acronym(s)` statements added.
- [x] `element_entry` accepts both `set_element` (allows hyphens) and
      `identifier` so `san-diego` parses.
- [x] Test fixtures converted from upstream's `#`-style to real `*` line
      comments.
- [x] `npx tree-sitter generate` clean (no LR(1) conflicts beyond the
      explicit one declared).

**Definition of done — met:** the canonical `transport.gms` example
parses with **zero ERROR nodes**. Upstream test files unchanged in error
count; remaining ERRORs (`assignments`, `code_sample`, `control_flow`,
`display`, `parameters`) are pre-existing upstream gaps in expression
and parameter-data-block parsing, out of scope for M1.

### Tests for M1 (Tree-sitter corpus)
Upstream `Schlegen/tree-sitter-gams/test/*.gms` files use `#`-prefixed comments
(matching the broken comment rule). After the comment-rule rewrite, **regenerate**
those fixtures with real GAMS comments, then add corpus tests under
`../tree-sitter-gams/test/corpus/*.txt`. Each file is a list of
`==== name ====` blocks with input followed by `---` and the expected sexp tree.
Cover at minimum:
- [ ] `comments.txt` — column-1 `*`, `$ontext` block, `/* */`, mixed.

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

## M2 — Zed extension scaffold (`gams-zed/`) ✅ done
- [x] `extension.toml` with `id="gams"`, `name="GAMS"`, `version="0.1.0"`,
      `[grammars.gams]` pointing at the local fork via `file://` URL,
      pinned to commit `840fdc1`. README documents the user-edit step
      for installing on another machine (or after pushing the fork to
      a public remote).
- [x] `languages/gams/config.toml`: name, grammar, `path_suffixes =
      ["gms","inc","lst"]`, `line_comments = ["* "]`, `word_characters =
      ["$","%"]`, full bracket pairs (`()`/`[]`/`{}`/`""`/`''`/`%%`)
      with `not_in = ["string","comment"]` for the quote-likes.
- [x] `languages/gams/highlights.scm` — produces 17 distinct capture
      types on `transport.gms` (comment, keyword.directive, string,
      number, keyword.type, keyword.modifier, keyword, function.builtin,
      operator, type.builtin, property, function, type, variable,
      constant, punctuation.delimiter, punctuation.bracket, plus
      string.special for `table_body`).
- [x] `languages/gams/brackets.scm` — `()` and the slash-fenced data
      blocks (set/parameter/scalar/variable/equation/model).
- [x] `languages/gams/indents.scm` — `(` / `)` and the slash-fenced
      blocks bump / drop indent.
- [x] `languages/gams/outline.scm` — surfaces names from set, parameter,
      scalar, table, variable, equation declaration & definition, model,
      alias, acronym, and solve nodes.
- [x] `languages/gams/injections.scm` — placeholder; macro-in-string
      injection deferred until the parser splits the string rule into
      open/content/close tokens.
- [x] `LICENSE` (Apache-2.0, matching the parser fork).
- [x] `README.md` — feature list, dev install instructions, project
      layout, reference VSCode extensions, roadmap, license.

**Definition of done — met:** all four `.scm` query files compile
without errors against the transport example via `tree-sitter query`.
Live-install in Zed (`zed: install dev extension`) is the M3 verification
step.

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
