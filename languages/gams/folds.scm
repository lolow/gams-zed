; Code folding queries for GAMS.
;
; Status: Zed currently folds based on indentation only; this file is
; ignored until issue zed-industries/zed#22703 lands. The parser
; already exposes the right structural nodes, so once Zed picks up
; folds.scm these blocks will fold without further changes.
;
; If your Zed install errors on this file, delete it — that means
; folds.scm is still unsupported. RELEASING.md gotcha #5.

; --- $ifthen / $elseIf / $else / $endif block ----------------------
(ifthen_block) @fold

; --- $onEcho / $offEcho block --------------------------------------
(onecho_block) @fold

; --- $onPut / $offPut block ----------------------------------------
(onput_block) @fold

; --- $onEmbeddedCode / $offEmbeddedCode block ----------------------
(onembedded_block) @fold

; --- Block comments ------------------------------------------------
(block_comment_dollar) @fold
(block_comment_c)      @fold

; --- Statement bodies that span multiple lines ---------------------
; Set / parameter / scalar / variable / equation / model declarations
; whose data block (the slash-fenced /…/) crosses lines.
(element_block)      @fold
(scalar_value_block) @fold
(param_data_block)   @fold
(var_data_block)     @fold
(eq_data_block)      @fold
(model_data_block)   @fold

; Equation definitions and indexed operations (sum / prod / loop) when
; their bodies wrap.
(equation_definition) @fold
(loop_statement)      @fold
(if_statement)        @fold
