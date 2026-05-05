# gams-zed sample fixtures

Four GAMS files exercising the full token spec. Each file parses with
**zero ERROR nodes**; together they trigger **every capture** declared
in `languages/gams/highlights.scm`.

## How to verify in Zed

After installing the dev extension (see top-level `README.md`):

```sh
zed gams-zed/tests/samples/
```

Open each file and confirm the highlights below. Compare against your
theme's actual scope colours — the *names* of the scopes are what
matters, not the specific colours.

## Programmatic check

From `tree-sitter-gams/`, after `tree-sitter generate`:

```sh
# Zero ERROR nodes on every sample:
for f in ../gams-zed/tests/samples/*; do
  tree-sitter parse "$f" 2>/dev/null \
    | grep -c ERROR \
    | xargs printf "%-30s %s\n" "$(basename $f)"
done

# Every highlights.scm capture fires at least once:
for f in ../gams-zed/tests/samples/*; do
  tree-sitter query ../gams-zed/languages/gams/highlights.scm "$f" 2>/dev/null
done | grep -oE 'capture: [^,]+ - [a-z._]+' | awk -F' - ' '{print $2}' | sort -u
```

## Sample 1 — `hello.gms`

Minimal model: comments, set, scalar, parameter, variables (with
`positive` modifier), equation declaration + definition, model, solve,
`loop`, display.

Lines 1–2  `* Minimal GAMS model …`           → `@comment`
Line   4   `set i / a, b, c /;`               → `@keyword.type` `@type` `@punctuation.bracket` `@constant` `@punctuation.delimiter`
Line   6   `scalar pi / 3.14 /;`              → `@keyword.type` `@type` `@number`
Line   8   `parameter w(i) / a 1, b 2, c 3 /;`→ `@keyword.type` `@type` `@variable` (domain `i`)
Lines 10–13 `variables x(i) 'choice variable' z 'objective' ;` → `@keyword.type` `@type` `@string`
Line  15   `positive variable x ;`            → `@keyword.modifier` `@keyword.type`
Lines 17–19 `equations total 'sum…' capacity(i) … ;` → `@keyword.type` `@type` `@string`
Line  21   `total.. z =E= sum(i, w(i) * x(i)) ;` → `@function` (`total`) `@operator` (`..` `=E=`) `@function.builtin` (`sum`) `@variable`
Line  22   `capacity(i)..  x(i) =L= 10 ;`     → `@function` (`capacity`) `@operator` (`=L=`)
Line  24   `model hello / all / ;`            → `@keyword.type` `@type`
Line  26   `solve hello using lp maximizing z ;` → `@keyword` (`solve`, `using`, `maximizing`) `@type.builtin` (`lp`)
Lines 28–31 `loop(i, display x.l(i) ;);`      → **`@keyword.repeat`** (`loop`) `@keyword` (`display`) `@property` (`.l`)
Line  33   `display x.l, z.l ;`               → `@keyword` `@property` (`l`)

## Sample 2 — `transport.gms`

The canonical GAMS transport model. Covers the same constructs as
`hello.gms` plus:

- **Quoted descriptions** on every declaration → `@string`
- **`table d(i,j) 'distance…'` … `;`** → `@keyword.type` (`table`) `@string` (description) `@string.special` (the 2D data block)
- **Three equation definitions** with `=E=`, `=L=`, `=G=` → `@operator`
- **Hyphenated set elements** `seattle, san-diego, new-york, chicago, topeka` → `@constant`
- **Parameter assignment** `c(i,j) = f * d(i,j) / 1000 ;` → `@variable` `@operator`
- **`positive variable x ;`** → `@keyword.modifier` `@keyword.type`
- **`solve transport using lp minimizing z ;`** → `@type.builtin` (`lp`)

## Sample 3 — `dollar_directives.gms`

Compile-time directives, conditional compilation, macro definition.

Each directive line should be uniformly coloured as `@keyword.directive`:

- `$title …`, `$set scenario base`, `$setglobal solver cplex`, `$setlocal limit 1000`
- `$ifThen %scenario% == base`, `$elseIf …`, `$else`, `$endif`
- `$onListing`, `$offSymList`
- `$$set rep_path "reports/%scenario%.gdx"` — note the `$$` inline form
- `$gdxIn input_%scenario%.gdx`, `$loadDC i, cost`, `$gdxOut`
- `$macro double(x) ((x)*(x))`
- `$exit`

Between the directives, a regular `set` and `parameter` declaration plus
a `scalar` and an assignment using a `$macro`-defined function. Verify:

- The directive lines render as one solid `@keyword.directive` block
  (the entire `$ifThen %scenario% == base` is one token; the macro
  reference inside is not separately captured because the directive is
  opaque)
- The `display "scenario %scenario% solver %solver% complete";` string
  is `@string`. Macro highlighting **inside** the string is deferred —
  the entire string body is one colour.

## Sample 4 — `edge_cases.inc`

Stress test for tricky lexical cases:

1. **Three comment forms in sequence** — column-1 `*`, multi-line
   `$ontext … $offtext`, `/* … */`. All `@comment`.
2. **Hyphenated set elements** `new-york, san-diego, los-angeles, topeka`
   → `@constant`. Without the `element_entry` fix, `san-diego` would be
   an ERROR node.
3. **Literal constants** `inf`, `eps`, `na`, `yes` → `@constant.builtin`
   inside `scalar … / … /` data blocks.
4. **Variable + equation suffixes** mixed in one expression:
   `x.l, x.up, x.lo, x.scale, balance.infeas, balance.slack` → `@property`.
5. **Range expansion** in set literals `t1 * t10`, `2020 * 2030` —
   the `*` between identifiers/numbers is an `@operator`, not the
   line-comment marker.
6. **All five common relational ops** `=E=`, `=L=`, `=G=`, `=N=`, `=X=`
   in equation definitions → `@operator`.
7. **MCP solve without direction** `solve mcp_demo using mcp ;` — no
   `minimizing`/`maximizing` clause → `@type.builtin` (`mcp`).
8. **Inline `$$exit`** at end of a statement line → `@keyword.directive`.
9. **Macro reference in expression** `cap_value = %limit% ;` →
   **`@constant.macro`**.

## Coverage status (auto-checked)

Run from `tree-sitter-gams/`:

| File                       | ERRORs | distinct captures fired |
|----------------------------|--------|-------------------------|
| `hello.gms`                | 0      | 16                      |
| `transport.gms`            | 0      | 16 (incl. `string.special`) |
| `dollar_directives.gms`    | 0      | 10                      |
| `edge_cases.inc`           | 0      | 17                      |
| **All four together**      | **0**  | **20** (every capture)  |

`@type` was deliberately dropped from declaration names (set, parameter,
scalar, variable, equation, model, alias, acronym, solve model) —
they render plain to avoid drawing attention to one-letter set names
like `set e`. `@type.builtin` (model types `lp/nlp/mip/...`) is still
captured. The captures are commented out in `highlights.scm` for
easy restoration.

If an ERROR appears or a capture goes missing, the cause is almost
always one of:
- A new directive form in column 0 that isn't `$ontext` (should still
  parse; check `tree-sitter-gams/src/scanner.c`).
- A new keyword the parser doesn't know yet (extend the relevant rule
  in `grammar.js`).
- A regression in `highlights.scm` after editing — re-run
  `tree-sitter query <file> sample.gms` to spot the missing pattern.
