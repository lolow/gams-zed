# Releasing gams-zed

This file tracks the manual steps for publishing a release of `gams-zed`
and (eventually) submitting it to the
[`zed-industries/extensions`](https://github.com/zed-industries/extensions)
registry.

## Pre-flight checklist

Before tagging, verify:

- [ ] `git status` is clean in both `gams-zed/` and `tree-sitter-gams/`.
- [ ] Every `tests/samples/*.gms` parses with **zero ERROR nodes**:
  ```sh
  for f in tests/samples/*; do
    out=$(../tree-sitter-gams/node_modules/.bin/tree-sitter parse "$f" 2>/dev/null)
    errs=$(echo "$out" | grep -c ERROR)
    printf "%-40s ERROR=%d\n" "$(basename "$f")" "$errs"
  done
  ```
- [ ] All four `.scm` query files compile:
  ```sh
  cd ../tree-sitter-gams
  for q in highlights brackets indents outline; do
    ./node_modules/.bin/tree-sitter query \
      ../gams-zed/languages/gams/$q.scm \
      ../gams-zed/tests/samples/transport.gms \
      > /dev/null && echo "OK   $q.scm"
  done
  ```
- [ ] `CHANGELOG.md` has an entry for the new version with a date.
- [ ] `extension.toml` `version` matches the new tag.
- [ ] `extension.toml` `[grammars.gams].rev` points at a real tag (not a
      branch, not `HEAD`) on a public remote.

## Release workflow

### 1. Push and tag the parser
```sh
cd ../tree-sitter-gams
# Ensure CHANGES.md is up to date for this version.
git tag -a vX.Y.Z -m "vX.Y.Z — <one-line summary>"
git push origin main vX.Y.Z
```
The CI workflow (`.github/workflows/test.yml`) runs on push and on tag.
Wait for it to go green.

### 2. Update extension.toml to the new parser tag
```sh
cd ../gams-zed
# In extension.toml: change [grammars.gams].rev to "vX.Y.Z" and
# .repository to the public HTTPS URL of the parser.
$EDITOR extension.toml
```
Local development typically uses `repository = "file:///abs/path/to/tree-sitter-gams"`;
**before submitting to the registry**, switch to the public URL,
e.g. `repository = "https://github.com/lolow/tree-sitter-gams"`.

### 3. Bump the extension version
```sh
$EDITOR extension.toml      # version = "X.Y.Z"
$EDITOR CHANGELOG.md        # add the X.Y.Z section
git commit -am "Release X.Y.Z"
git tag -a vX.Y.Z -m "vX.Y.Z — <one-line summary>"
git push origin main vX.Y.Z
```

### 4. Submit / update in the Zed extensions registry
Zed extensions live in
[`zed-industries/extensions`](https://github.com/zed-industries/extensions).
The registry uses **git submodules** to pull in extension repositories.

For a **first submission**:

1. Fork `zed-industries/extensions`.
2. Add `gams-zed` as a submodule under `extensions/`:
   ```sh
   git submodule add https://github.com/lolow/gams-zed.git extensions/gams
   git -C extensions/gams checkout vX.Y.Z
   ```
3. Run the registry's helper script to update `extensions.toml`
   (each submission must register the extension's `id`, `name`,
   `description`, `path`, and `version`). See the registry's own
   `CONTRIBUTING.md` for the current commands.
4. Commit and open a PR. The PR template asks for the extension
   metadata, a screenshot, and a confirmation that the extension
   builds locally.

For a **version bump** of an already-submitted extension:

1. Update the submodule pointer to the new tag.
2. Bump the version string in `extensions.toml`.
3. Commit and PR.

### 5. After merge
- Verify the extension appears in `zed: extensions` in a fresh Zed
  install (without `zed: install dev extension`).
- Tag the GitHub release on `gams-zed` with the same `vX.Y.Z` and
  paste the changelog entry into the release body.

## Zed packaging constraints (lessons from v0.1.0)

Three issues bit us on the first install; if you change the parser or the
extension's grammar pin, watch for these:

1. **`pathspec '<tag>' did not match …`**
   Zed's grammar fetcher does a shallow clone of the source at
   `[grammars.<id>].repository`. The shallow clone does NOT pull
   tags — true for `file://`, true for `https://`, true for `ssh://`.
   *Fix:* always pin `rev` to a commit SHA, never a tag name. Bumps
   between releases are a one-line edit; the SHA-vs-tag inconvenience
   is a one-time annoyance.

2. **`no such file or directory: 'src/parser.c'`**
   Zed does not run `tree-sitter generate` on the grammar; it expects
   `src/parser.c`, `src/grammar.json`, `src/node-types.json`, and
   `src/tree_sitter/*.h` to be checked into the parser repo. The
   convention every published `tree-sitter-*` repo follows. Don't put
   those files in `.gitignore` — only ignore `node_modules/` and
   `package-lock.json`. CI keeps the generated artefacts in sync via
   `tree-sitter generate` on every push.

3. **`Failed to instantiate Wasm module: invalid import '<libc-fn>'`**
   The grammar (parser.c + scanner.c) is compiled to WebAssembly. WASM
   provides no libc, so anything from `<ctype.h>` (`tolower`, `isalpha`,
   `isdigit`, …) or `<stdlib.h>` (beyond `malloc`/`free` which the
   tree-sitter runtime supplies) breaks loading. Hand-roll equivalents
   for ASCII inputs — see `ascii_tolower` in
   `../tree-sitter-gams/src/scanner.c`.

4. **`missing required capture in injections … query: content or injection.content`**
   Zed auto-loads every `.scm` file under `languages/<lang>/`. An empty
   `injections.scm` (or one without an `@injection.content` capture)
   triggers this error and the language fails to load. If there's
   nothing to inject yet, **delete the file** rather than leaving a
   placeholder — Zed simply skips injection processing when the file
   isn't present.

5. **`folds.scm` may or may not be honoured.**
   Syntax-aware folding via `folds.scm` is tracked in
   [zed-industries/zed#22703](https://github.com/zed-industries/zed/issues/22703)
   and not yet shipped as of mid-2026; Zed currently folds based on
   indentation only. We pre-seeded `languages/gams/folds.scm` with
   `@fold` captures for every paired block (ifthen/onecho/onput/
   onembedded, block comments, slash-fenced data blocks, equation
   definitions, control-flow statements). When Zed lands the feature
   the file activates with no parser change.

   If a future Zed version errors on this file the way an empty
   `injections.scm` does, delete it and revisit when the feature
   becomes documented in [Zed's language-extension docs]
   (https://zed.dev/docs/extensions/languages).

## Versioning policy

Semantic versioning. Patch releases for bug fixes only. A change that
adds new highlight captures or new node-type matches is **minor**
(0.1 → 0.2). A change that renames or removes captures is **major**
(0.x → 1.0).

Parser releases (`tree-sitter-gams`) follow their own semver, but the
extension always pins a specific parser tag and bumps along with it.
