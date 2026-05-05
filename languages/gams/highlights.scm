; GAMS syntax highlighting queries.
;
; Capture conventions follow Zed's standard set (see
; https://zed.dev/docs/extensions/languages). Captures resolve right-to-left,
; so more specific captures should appear LATER in the file.

; ---------- Comments ---------------------------------------------------
(line_comment)         @comment
(block_comment_c)      @comment
(block_comment_dollar) @comment

; ---------- Dollar directives ($include, $set, $ifThen, ...) -----------
; Colour the $name keyword as a directive; the argument tail picks up
; the surrounding theme's default text colour, except for the
; $if/$ifThen test-words (set/exist/declared/...) below, which are
; coloured the same as the directive itself.
(dollar_directive_keyword) @keyword.directive

; Test-words inside $if / $ifThen condition expressions. Each space-
; separated word in directive args is its own `directive_text` node;
; the #match? predicate filters to the GAMS-defined keywords. Pattern
; is anchored end-to-end so partial matches like `note` don't trigger.
((directive_text) @keyword.directive
 (#match? @keyword.directive
   "^([nN][oO][tT]|[aA][nN][dD]|[oO][rR]|[xX][oO][rR]|[iI][mM][pP]|[eE][qQ][vV]|[sS][eE][tT]|[dD][eE][cC][lL][aA][rR][eE][dD]|[dD][eE][fF][iI][nN][eE][dD]|[eE][xX][iI][sS][tT]|[sS][eE][tT][eE][nN][vV]|[eE][rR][rR][oO][rR][fF][rR][eE][eE]|[eE][rR][rR][oO][rR][lL][eE][vV][eE][lL]|[wW][aA][rR][nN][iI][nN][gG]|[dD][sS][eE][tT]|[dD][pP][aA][rR]|[dD][vV][aA][rR]|[dD][eE][qQ][nN]|[dD][mM][oO][dD]|[dD][fF][uU][nN]|[dD][aA][cC][rR]|[eE][qQ]|[nN][eE]|[gG][tT]|[gG][eE]|[lL][tT]|[lL][eE])$"))

; ---------- String / number / macro literals ---------------------------
(string)    @string
(number)    @number
(macro_ref) @constant.macro
(bool)      @constant.builtin

; ---------- Declaration keywords (storage type) -----------------------
(set_keyword)        @keyword.type
(parameter_keyword)  @keyword.type
(scalar_keyword)     @keyword.type
(table_keyword)      @keyword.type
(variable_keyword)   @keyword.type
(equation_keyword)   @keyword.type
(model_keyword)      @keyword.type
(alias_keyword)      @keyword.type
(acronym_keyword)    @keyword.type

; ---------- Variable type modifiers (positive / binary / ...) ---------
(var_type) @keyword.modifier

; ---------- Statement keywords ----------------------------------------
(solve_keyword)      @keyword
(solve_direction)    @keyword
(display_keyword)    @keyword
(loop_keyword)       @keyword.repeat

; The if / elseif / else / option / abort introducer tokens are produced
; by `caseInsensitive(...)` regex rules in the parser, not literal
; strings, so they are anonymous and cannot be captured by query string
; literals. Their parent statement nodes are visible (if_statement,
; option_statement, abort_statement); a future parser change would
; promote the introducers to named keyword rules and let us colour them
; explicitly.

; ---------- Built-in functions ----------------------------------------
(unary_builtin_function_keyword)      @function.builtin
(binary_builtin_function_keyword)     @function.builtin
(multi_args_builtin_function_keyword) @function.builtin
(indexed_operation_keyword)           @function.builtin

; ---------- Operators -------------------------------------------------
(binary_operator_keyword) @operator
(equation_definition_op)  @operator
(equation_relational_op)  @operator
(unary_expr ["+" "-"] @operator)

; ---------- Solver model types (lp / nlp / mip / ...) -----------------
(model_type) @type.builtin

; ---------- Suffix attributes (.l, .lo, .up, .range, ...) -------------
(variable_attribute_keyword) @property

; ---------- Equation definition: name slot is the equation name -------
(equation_definition
  name: (identifier) @function)
(equation_definition
  name: (identifier_with_domain
    (identifier) @function))

; ---------- Solve statement: objective slot ---------------------------
; The model name and objective are plain identifiers — no special scope
; (matches the convention that declaration NAMES are not highlighted).
;
; ---------- Set / parameter / scalar / variable / equation entries ----
; Declaration names (the symbol being introduced) render plain so a
; one-letter set like `set e ...` doesn't visually compete with set
; elements or expression identifiers. If you want them coloured back
; in, restore the captures below — `@type` is the conventional scope.
;
; (set_entry           (identifier) @type)
; (scalar_entry        (identifier) @type)
; (param_entry         (identifier) @type)
; (var_entry           (identifier) @type)
; (eq_entry            (identifier) @type)
; (model_entry         (identifier) @type)
; (acronym_declaration (identifier) @type)
; (solve_statement     model: (identifier) @type)

; Domain identifiers inside identifier_with_domain are existing set names.
(identifier_with_domain
  (identifier_with_domain_args (identifier) @variable))

; ---------- Set elements ---------------------------------------------
; Set elements (literal values inside `set foo / a, b, c /`) and the
; parts of a multi-dimensional tuple element (`co2.co2_daccs`) all
; render with the @type scope. Most themes colour @type yellow, which
; makes the catalogue of set members stand out from declaration
; names (which we deliberately leave plain).
(set_element)             @type
(element_entry
  (identifier) @type)
(element_entry
  (set_element) @type)

; ---------- Bare identifiers in expressions --------------------------
(bare_identifier) @variable

; ---------- Macro / option / table body content ----------------------
; Table body is opaque; mark it as a string-ish region so it stays
; visually grouped.
(table_body) @string.special

; ---------- Punctuation ----------------------------------------------
[
  ";"
  ","
] @punctuation.delimiter

[
  "("
  ")"
  "/"
] @punctuation.bracket

; ---------- Conditional / dollar operator ----------------------------
(conditional_expr "$" @operator)
(loop_statement "$" @operator)
(indexed_operation "$" @operator)
(assignment_statement
  condition: (_) "$" @operator)
