# GAMS token specification — gams-zed

Canonical token list for the Zed GAMS extension. Merges:

- **L** = `../gams/syntaxes/Gams.tmLanguage` (lolow, plist)
- **V** = `../vscode-gams/syntaxes/gams_org.tmGrammar.json` (eunseong-park, JSON)
- **S** = `Schlegen/tree-sitter-gams` `grammar.js` (existing parser)

Each row marks coverage in the source grammars, the planned **Zed scope**
(`@…` capture in `highlights.scm`), and **status**: `in-scope` (must work in
v0.1), `polish` (v0.2 nice-to-have), `deferred` (post-1.0).

GAMS is **case-insensitive**. Examples are shown in the canonical lowercase form.

---

## 1. Comments & whitespace

| # | Token | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 1.1 | Column-1 line comment | `* this is a comment` (only when `*` is in column 1) | ✓ | ✓ | ✗ (broken: `#` regex) | `@comment` | in-scope |
| 1.2 | Dollar block comment | `$ontext … $offtext` and `$$ontext … $$offtext` (case-i) | ✓ | ✓ | ✗ | `@comment` | in-scope |
| 1.3 | C-style block comment | `/* … */` | ✓ | ✓ | ✗ | `@comment` | in-scope |
| 1.4 | EOL comment (`//`, `!!`) | `// inline` (only after `$eolcom //`) | ✓ | ✓ | ✗ | `@comment` | polish (state-dependent) |
| 1.5 | Inline comment (`{ … }`) | `x = 1 { note } ;` (only after `$inlinecom { }`) | ✗ | ✗ | ✗ | `@comment` | deferred |

> **L bug:** lolow's `linecomment` regex includes `#` — non-standard, do not port.
> **V refinement:** excludes `$ontext … mpsge` blocks from the block-comment
> rule (those are MPSGE code, not text). Track in the parser fork.

---

## 2. String literals

| # | Token | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 2.1 | Double-quoted string | `"hello"` | ✓ | ✓ | ✓ | `@string` | in-scope |
| 2.2 | Single-quoted string | `'hello'` | ✓ | ✓ | ✓ | `@string` | in-scope |
| 2.3 | `%macro%` inside string | `"file_%scen%.gdx"` | ✓ | ✓ | ✗ | `@constant.macro` (injection) | in-scope |
| 2.4 | Apostrophe inside identifier | `it's` (V uses lookbehind to avoid eating identifiers) | ✗ | ✓ | ✗ | n/a (lexer guard) | in-scope |

---

## 3. Numbers & literal constants

| # | Token | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 3.1 | Integer | `42` | ✓ | ✓ | ✓ | `@number` | in-scope |
| 3.2 | Decimal | `3.14`, `.5` | ✓ | ✓ | ✓ | `@number` | in-scope |
| 3.3 | Scientific | `1.5e-3`, `2E+10` | ✓ | ✓ | ✓ | `@number` | in-scope |
| 3.4 | Special — `inf` | `INF`, `-INF` | ✓ | ✓ | ✗ | `@constant.builtin` | in-scope |
| 3.5 | Special — `na` | `NA` | ✓ | ✓ | ✗ | `@constant.builtin` | in-scope |
| 3.6 | Special — `eps` | `EPS` | (kw) | ✗ | ✗ | `@constant.builtin` | in-scope |
| 3.7 | Booleans | `yes`, `no` | ✓ | ✓ | ✓ | `@constant.builtin` | in-scope |

---

## 4. `%macro%` references (compile-time variables)

| # | Token | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 4.1 | Plain macro | `%scenario%` | ✓ | ✓ | ✗ | `@constant.macro` | in-scope |
| 4.2 | Numeric macro arg | `%1`, `%2` | ✓ | ✗ | ✗ | `@constant.macro` | in-scope |

---

## 5. Dollar control directives (`$keyword` in column 1, `$$keyword` inline)

The full list lives in GAMS docs. Both **L** and **V** ship enumerations; **V**'s
list is the more complete (mixed-case names, MPSGE additions, modern aliases).
For the parser fork we will:
1. Match `$\$?[A-Za-z_]+` greedy as a *directive token*.
2. Highlight via a curated keyword list (subset below).

| # | Group | Members (curated) | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|---|
| 5.1 | Include / call | `include`, `batinclude`, `libinclude`, `sysinclude`, `call`, `callTool`, `hiddenCall` | `$include data.gms` | ✓ | ✓ | ✗ | `@keyword.directive` | in-scope |
| 5.2 | Conditionals | `if`, `ifThen`, `ifThenE`, `ifThenI`, `else`, `elseIf`, `endif`, `goto`, `label` | `$ifThen %mode% == LP` | ✓ | ✓ | ✗ | `@keyword.directive` | in-scope |
| 5.3 | Variables | `set`, `setGlobal`, `setLocal`, `eval`, `evalGlobal`, `evalLocal`, `drop`, `dropGlobal`, `dropLocal` | `$setglobal scen base` | ✓ | ✓ | ✗ | `@keyword.directive` | in-scope |
| 5.4 | I/O | `gdxIn`, `gdxOut`, `gdxLoad`, `gdxLoadAll`, `gdxUnload`, `load`, `loadDC`, `loadDCM`, `loadM`, `loadR`, `loadFiltered`, `unload` | `$gdxin in.gdx` | ✓ | ✓ | ✗ | `@keyword.directive` | in-scope |
| 5.5 | Listing toggles | `(on|off)Listing`, `(on|off)Echo`, `(on|off)Eolcom`, `(on|off)Margin`, `(on|off)Symxref`, `(on|off)Uellist`, `(on|off)Empty`, … | `$onempty` | ✓ | ✓ | ✗ | `@keyword.directive` | in-scope |
| 5.6 | Macros / utility | `macro`, `funcLibIn`, `phantom`, `protect`, `purge`, `kill`, `clear`, `compress`, `decompress`, `comment`, `dollar`, `eolCom`, `inlineCom` | `$macro f(x) x*x` | ✓ | ✓ | ✗ | `@keyword.directive` | in-scope |
| 5.7 | Control / debug | `abort`, `abort.noError`, `error`, `terminate`, `stop`, `exit`, `log`, `version`, `title`, `sTitle`, `remark`, `echo`, `echoN` | `$abort.noError` | ✓ | ✓ | ✗ | `@keyword.directive` | in-scope |
| 5.8 | MPSGE bridge | `$model`, `$sectors`, `$commodities`, `$consumers`, `$auxiliaries`, `$prod`, `$demand`, `$constraint`, `$report` | `$sectors:` | ✗ | ✓ | ✗ | `@keyword.directive` | polish |
| 5.9 | Legacy / deprecated | `use205`, `use225`, `use999` | | ✓ | ✓ | ✗ | `@keyword.directive` | deferred |
| 5.10 | Embedded code | `$onEmbeddedCode python:`, `$offEmbeddedCode`, `$onExternalInput`, `$onExternalOutput` | ✗ | partial | ✗ | `@keyword.directive` (start/end), body via injection | polish |

> **Implementation:** the parser should **not** hard-code each name; it should
> tokenize the whole `$identifier` as one node and let `highlights.scm` filter
> known names from unknown via a `(#match? @keyword.directive "^...")` predicate
> (or fall back to `@keyword.directive` with `@variable` for unknown directives).

---

## 6. Declaration keywords (with optional modifiers)

| # | Keyword | Modifiers | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|---|
| 6.1 | `set(s)` | `singleton` | `singleton set i / a /;` | ✓ | ✓ | ✓ | `@keyword.type` | in-scope |
| 6.2 | `parameter(s)` | — | `parameter p(i);` | ✓ | ✓ | ✓ | `@keyword.type` | in-scope |
| 6.3 | `scalar(s)` | — | `scalar pi / 3.14 /;` | ✓ | ✓ | ✓ | `@keyword.type` | in-scope |
| 6.4 | `table` | — | `table d(i,j) …` | ✓ | ✓ | ✗ | `@keyword.type` | in-scope |
| 6.5 | `variable(s)` | `free`, `positive`, `nonnegative`, `negative`, `binary`, `integer`, `sos1`, `sos2`, `semicont`, `semiint` | `positive variable x(i,j);` | partial | ✓ | ✓ | `@keyword.type` (kw), `@keyword.modifier` (mod) | in-scope |
| 6.6 | `equation(s)` | — | `equations cost, bal(i);` | ✓ | ✓ | ✓ | `@keyword.type` | in-scope |
| 6.7 | `model(s)` | — | `model m / all /;` | (kw) | ✓ | ✓ | `@keyword.type` | in-scope |
| 6.8 | `alias` | — | `alias(i,j);` | (kw) | ✓ | ✓ | `@keyword.type` | in-scope |
| 6.9 | `acronym(s)` | — | `acronym mon, tue;` | (kw) | ✓ | ✗ | `@keyword.type` | in-scope |
| 6.10 | `function(s)` | — | `functions f, g;` | ✗ | ✓ | ✗ | `@keyword.type` | polish |
| 6.11 | `file(s)` | — | `files out / 'out.txt' /;` | (kw) | ✓ | ✗ | `@keyword.type` | polish |

---

## 7. Equation definition syntax

| # | Token | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 7.1 | `..` defining symbol | `cost.. z =E= sum(i, c(i)*x(i));` | ✓ | ✓ | ✗ | `@operator.equation` | in-scope |
| 7.2 | `=e=` equality | | ✓ | ✓ | ✗ | `@operator.equation` | in-scope |
| 7.3 | `=l=` ≤ | | ✓ | ✓ | ✗ | `@operator.equation` | in-scope |
| 7.4 | `=g=` ≥ | | ✓ | ✓ | ✗ | `@operator.equation` | in-scope |
| 7.5 | `=n=` no relation | | ✗ | ✗ | ✗ | `@operator.equation` | in-scope |
| 7.6 | `=x=` external | | ✓ | ✓ | ✗ | `@operator.equation` | in-scope |
| 7.7 | `=c=` cone (MCP) | | ✗ | ✗ | ✗ | `@operator.equation` | polish |
| 7.8 | `=b=` boolean | | ✗ | ✗ | ✗ | `@operator.equation` | polish |

> Both reference grammars miss `=n=`, `=c=`, `=b=`. Add to the parser fork.

---

## 8. Solve statement & model types

| # | Token | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 8.1 | `solve` | `solve m using lp minimizing z;` | ✓ | ✓ | ✓ | `@keyword` | in-scope |
| 8.2 | `using` | | ✓ | ✓ | ✓ | `@keyword` | in-scope |
| 8.3 | `minimizing`, `maximizing` | | ✓ | ✓ | ✓ | `@keyword` | in-scope |
| 8.4 | Model type literal | `lp`, `nlp`, `mip`, `rmip`, `minlp`, `rminlp`, `qcp`, `miqcp`, `mcp`, `mpec`, `dnlp`, `cns`, `emp` | ✗ | ✓ | ✗ | `@type.builtin` | in-scope |

---

## 9. Control flow

| # | Token | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 9.1 | `if`, `then`, `else`, `elseif` | `if (x>0, …);` | ✓ | ✓ | ✓ | `@keyword.conditional` | in-scope |
| 9.2 | `loop` | `loop(i, …);` | ✓ | ✓ | ✓ | `@keyword.repeat` | in-scope |
| 9.3 | `while`, `repeat`, `until`, `for` | | ✓ | ✓ | ✗ | `@keyword.repeat` | in-scope |
| 9.4 | `abort`, `display`, `option(s)`, `put`, `putpage`, `puttl`, `putclose`, `put_utility` | | ✓ | ✓ | partial | `@keyword` | in-scope |
| 9.5 | `execute_load`, `execute_unload`, `execute_loaddc` | | ✓ | ✓ | ✗ | `@keyword` | in-scope |
| 9.6 | `sameas`, `exist` | | ✓ | ✓ | ✗ | `@function.builtin` | in-scope |
| 9.7 | Logical words | `and`, `or`, `not`, `xor`, `eq`, `ne`, `gt`, `ge`, `lt`, `le` | ✓ | ✓ | partial | `@keyword.operator` | in-scope |

---

## 10. Built-in math/aggregate functions

(Full list is in **L/V** `math` rule — copy verbatim.)

| Group | Members |
|---|---|
| Aggregators | `sum`, `prod`, `smin`, `smax`, `sand`, `sor` |
| Set funcs | `card`, `ord`, `sameas`, `val` |
| Math (1-arg) | `abs`, `arccos`, `arcsin`, `arctan`, `ceil`, `cos`, `cosh`, `exp`, `fact`, `floor`, `frac`, `log`, `log2`, `log10`, `sign`, `sin`, `sinh`, `sqr`, `sqrt`, `tan`, `tanh`, `trunc` |
| Math (2-arg) | `arctan2`, `centropy`, `cvpower`, `div`, `div0`, `edist`, `entropy`, `errorf`, `gamma`, `gammareg`, `logbeta`, `loggamma`, `mapval`, `max`, `min`, `mod`, `power`, `rpower`, `signpower`, `slexp`, `sllog10`, `slrec`, `sqexp`, `sqlog10`, `sqrec`, `vcpower` |
| Math (boolean) | `bool_and`, `bool_eqv`, `bool_imp`, `bool_not`, `bool_or`, `bool_xor` |
| Random | `normal`, `uniform`, `uniformint`, `randbinomial`, `randlinear`, `randtriangle`, `binomial`, `beta`, `betareg` |
| Solver-bridge | `ncpcm`, `ncpf`, `ncpvupow`, `ncpvusin`, `sigmoid`, `poly`, `pi` |
| Misc | `execseed`, `ifthen` |

| | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|
| All of the above | ✓ | ✓ | partial (only the ones in `unary_builtin_function_keyword`, `binary_builtin_function_keyword`, `multi_args_builtin_function_keyword`) | `@function.builtin` | in-scope |

---

## 11. Suffixes (dot-attributes after a symbol)

| # | Group | Members | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 11.1 | Variable level/bounds | `.l`, `.lo`, `.up`, `.fx`, `.m`, `.scale`, `.prior`, `.stage` | ✓ | ✓ | ✓ (`l/lo/up/fx/m/scale`) | `@property` | in-scope |
| 11.2 | Equation slack/range | `.range`, `.slackup`, `.slacklo`, `.slack`, `.infeas` | ✗ | ✓ | ✗ | `@property` | in-scope |
| 11.3 | Output formatting | `.lj`, `.nj`, `.sj`, `.tj`, `.lw`, `.nw`, `.sw`, `.tw`, `.nd`, `.nr`, `.nz`, `.tf`, `.ts`, `.tl`, `.te`, `.tm`, `.bm`, `.pc`, `.ps`, `.pw`, `.ll`, `.lp`, `.ws`, `.case`, `.date`, `.cc`, `.hdcc`, `.tlcc`, `.lcase`, `.cr`, `.hdcr`, `.tlcr`, `.errors`, `.hdll`, `.tlll`, `.pdir`, `.lm` | ✓ | ✓ | ✗ | `@property` | in-scope |
| 11.4 | System metadata | `.ifile`, `.ofile`, `.page`, `.rdate`, `.rfile`, `.rtime`, `.sfile`, `.time`, `.title`, `.iline`, `.fp`, `.fn`, `.fe`, `.platform`, `.gamsversion`, `.gamsrelease`, `.computername`, `.username`, `.userconfigdir`, `.userdatadir`, `.line`, `.listline`, `.prline`, `.prpage`, `.opage`, `.elapsed`, `.error`, `.errorlevel`, `.tab`, `.gstring`, `.sstring`, `.dirsep`, `.filesys`, `.licenselevel`, `.licensefilename`, `.macaddress`, `.maxinput`, `.memory`, `.nullfile`, `.pfile`, `.putfilename`, `.tcomp`, `.texec`, `.tstart`, `.tclose`, `.title` | ✗ | ✓ | ✗ | `@property` | polish |
| 11.5 | Set-element introspection | `.pos`, `.ord`, `.off`, `.rev`, `.uel`, `.len`, `.tlen`, `.val`, `.tval`, `.first`, `.last` | ✗ | ✓ | ✗ | `@property` | polish |
| 11.6 | Solver/result metadata | `.modelstat`, `.solvestat`, `.numvar`, `.numequ`, `.numinfes`, `.numnopt`, `.objval`, `.resusd`, `.iterusd`, `.solprint`, `.handle`, `.solvelink`, … | ✗ | ✗ | ✗ | `@property` | polish |
| 11.7 | Model type per-model | `.lp`, `.nlp`, `.mip`, `.minlp`, `.miqcp`, `.qcp`, `.mcp`, `.mpec`, `.cns`, `.dnlp`, `.emp`, `.rminlp`, `.rmip`, `.rmiqcp`, `.rmpec` | ✗ | ✓ | ✗ | `@type.builtin` | polish |

---

## 12. Operators & punctuation

| # | Token | Members | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 12.1 | Arithmetic | `+`, `-`, `*`, `/`, `**` | ✓ | ✓ | ✓ | `@operator` | in-scope |
| 12.2 | Comparison | `=`, `<`, `>`, `<=`, `>=`, `<>` | ✓ | ✓ | ✓ | `@operator` | in-scope |
| 12.3 | Logical (word) | `and`, `or`, `not`, `xor` | ✓ | ✓ | partial | `@keyword.operator` | in-scope |
| 12.4 | Logical (mnemonic) | `eq`, `ne`, `gt`, `ge`, `lt`, `le` | ✓ | ✓ | partial | `@keyword.operator` | in-scope |
| 12.5 | Conditional | `$` (when used as condition operator, not directive) | ✓ | ✓ | ✓ | `@operator` | in-scope |
| 12.6 | Set-element separator | `.` (in tuples like `i.j.k`) | ✗ | ✗ | ✓ | `@punctuation.delimiter` | in-scope |
| 12.7 | Statement terminator | `;` | ✓ | ✓ | ✓ | `@punctuation.delimiter` | in-scope |
| 12.8 | Brackets | `(` `)` `[` `]` `{` `}` | (kw) | (kw) | ✓ | `@punctuation.bracket` | in-scope |
| 12.9 | Slash delimiters (data) | `/` `…` `/` (set/parameter/scalar data blocks) | ✓ | ✓ | ✓ | `@punctuation.delimiter` | in-scope |
| 12.10 | Range expansion | `*` between two set elements (e.g. `t1*t10`) | ✗ | ✗ | ✓ | `@operator` | in-scope |

---

## 13. Solver options (top-level `option` statement)

| # | Group | Members | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 13.1 | `option` keyword | `option iterlim=1000;` | ✓ | ✓ | ✗ | `@keyword` | in-scope |
| 13.2 | Option names | `iterlim`, `reslim`, `optcr`, `optca`, `limrow`, `limcol`, `domlim`, `decimals`, `solprint`, `solvelink`, `sysout`, `trace`, `threads`, `profile`, `bratio`, `badeps`, `debug`, `lp`, `mip`, `nlp` | ✗ | ✓ | ✗ | `@variable.builtin` | polish |

---

## 14. Identifiers & references

| # | Token | Example | L | V | S | Zed scope | Status |
|---|---|---|---|---|---|---|---|
| 14.1 | Plain identifier | `x`, `myvar` | (default) | (default) | ✓ | `@variable` | in-scope |
| 14.2 | Domain reference | `x(i,j)` | (default) | (default) | ✓ | `@variable` (call), args `@variable.parameter` | in-scope |
| 14.3 | Suffix reference | `x.l(i)`, `m.modelstat` | ✓ | ✓ | ✓ | `@variable` `.` `@property` | in-scope |
| 14.4 | Domain element | `'a'`, `a` (inside set definitions) | (default) | (default) | ✓ | `@string` (quoted) / `@constant` (bare) | in-scope |

---

## 15. Deferred (post-1.0)

- Listing-file (`.lst`) syntax: solve summary, error markers, `**** EXECUTION` banners.
- `put` file-writing DSL with format strings (`x:0:2`, `@col`, `#row`).
- Embedded code blocks: `$onEmbeddedCode python: … $offEmbeddedCode` (with
  Python/Connect/GAMS embedded-code body injected as `python` / `connect`).
- MPSGE blocks (sectors/commodities/consumers/prod/demand) — partial in V.
- LSP-driven semantics: undefined-symbol underlines, type-of-symbol disambiguation.

---

## 16. Cross-check log (M0)

- Real-world `.gms` files in `Schlegen/tree-sitter-gams/test/` use `#`-prefixed
  comments because the grammar's comment rule is wrong. Our fork must rewrite
  these fixtures with `*` column-1 / `$ontext` blocks before re-running the
  corpus.
- The `model_item` rule in S correctly handles the set-arithmetic forms
  `three-one`, `four+two`, `three-configure_eq` seen in `model.gms`. Keep.
- Both `solve m using lp minimizing z` and `solve m minimizing z using lp`
  forms are in real test data; S handles both.
- Categories cross-checked against
  [GAMS Dollar Control Options docs](https://www.gams.com/latest/docs/UG_DollarControlOptions.html):
  9 official categories all map to §5 sub-rows. Embedded code added as §5.10
  (polish) — full body parsing remains deferred to §15.

---

## Coverage summary

| Source | Comments | Strings | Numbers | Macros | Directives | Decls | Eq.def | Solve | Suffix | Functions |
|---|---|---|---|---|---|---|---|---|---|---|
| **L** (lolow) | ✓ | ✓ | ✓ | ✓ | ✓ (legacy list) | ✓ | ✓ | ✓ | ✓ (basic) | ✓ |
| **V** (vscode-gams) | ✓ | ✓ + apostrophe guard | ✓ | ✓ | ✓ (modern + MPSGE) | ✓ + acronym/file/function | ✓ | ✓ + modeltype | ✓ (extensive) | ✓ |
| **S** (Schlegen ts) | ✗ broken | ✓ | ✓ | ✗ | ✗ | ✓ (no table) | ✗ | partial | partial | partial |

**Implication for the parser fork:** the gaps to close in `Schlegen/tree-sitter-gams`
to reach v0.1 of gams-zed are §1.1–§1.3 (comments), §3.4–§3.6 (special numbers),
§4 (macros), §5 (dollar directives), §6.4 (table), §7 (equation definitions
with `=e=/=l=/=g=/=n=/=x=`), §8.4 (model types), §11.2 (equation suffixes),
§12.6 / §12.10 (set-element `.` and range `*`).
