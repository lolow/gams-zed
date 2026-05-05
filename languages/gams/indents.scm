; Indentation rules for GAMS.
;
; @indent fires at a node opening that should bump the indent level for
; the next line. @end fires at the closing token that should drop it.

; Argument lists, indexed operations, and equation conditions all open
; with '(' and close with ')'.
"(" @indent
")" @end

; Slash-fenced data blocks: opening '/' bumps indent, closing '/' drops.
(element_block      "/" @indent)
(scalar_value_block "/" @indent)
(param_data_block   "/" @indent)
(var_data_block     "/" @indent)
(eq_data_block      "/" @indent)
(model_data_block   "/" @indent)
