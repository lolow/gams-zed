; Bracket-matching pairs for GAMS.
;
; The parser exposes only the brackets it actually uses: '(' / ')' for
; argument lists and '/' as a slash-fence around set/parameter/scalar
; data blocks. '[' ']' '{' '}' '"' "'" '%' are allowed by the language
; configuration's autoclose pairs but are not part of the parse tree;
; they get bracket-match behaviour from Zed's text-level pairing.

("(" @open ")" @close)

; Slash-fenced data blocks: parameter / set / scalar value initialisers
; live between matching '/' tokens. Tagging both as open / close lets
; Zed jump between them.
(element_block      "/" @open "/" @close)
(scalar_value_block "/" @open "/" @close)
(param_data_block   "/" @open "/" @close)
(var_data_block     "/" @open "/" @close)
(eq_data_block      "/" @open "/" @close)
(model_data_block   "/" @open "/" @close)
