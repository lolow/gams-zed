; Currently empty: macro_ref tokens (%name%) inside strings are not
; surfaced as separate parse-tree children by the upstream string rule
; (`'…'` and `"…"` are atomic). Promoting them would require splitting
; the string rule into open / interpolated / close tokens.
