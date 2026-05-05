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
(dollar_directive) @keyword.directive

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

; ---------- Solve statement: model + objective slots ------------------
(solve_statement
  model: (identifier) @type)
(solve_statement
  objective: (identifier) @variable)

; ---------- Set / parameter / scalar / variable / equation entries ----
; The first identifier in each entry is the symbol being declared.
(set_entry       (identifier) @type)
(scalar_entry    (identifier) @type)
(param_entry     (identifier) @type)
(var_entry       (identifier) @type)
(eq_entry        (identifier) @type)
(model_entry     (identifier) @type)
(acronym_declaration (identifier) @type)

; Domain identifiers inside identifier_with_domain are existing set names.
(identifier_with_domain
  (identifier_with_domain_args (identifier) @variable))

; ---------- Set elements ---------------------------------------------
(set_element)         @constant
(element_entry
  (identifier) @constant)

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
