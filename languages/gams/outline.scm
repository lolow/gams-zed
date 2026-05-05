; Symbol outline for GAMS.
;
; Each top-level declaration becomes one outline item. The leading
; keyword (set/parameter/...) is captured as @context so it shows beside
; the symbol name in the outline tree.

; --- set declarations ---
(set_declaration
  (set_keyword) @context
  (set_entry
    (identifier) @name)) @item

(set_declaration
  (set_keyword) @context
  (set_entry
    (identifier_with_domain
      (identifier) @name))) @item

; --- parameter declarations ---
(parameter_declaration
  (parameter_keyword) @context
  (param_entry
    (identifier) @name)) @item

(parameter_declaration
  (parameter_keyword) @context
  (param_entry
    (identifier_with_domain
      (identifier) @name))) @item

; --- scalar declarations ---
(scalar_declaration
  (scalar_keyword) @context
  (scalar_entry
    (identifier) @name)) @item

; --- table declarations ---
(table_declaration
  (table_keyword) @context
  name: (identifier) @name) @item

(table_declaration
  (table_keyword) @context
  name: (identifier_with_domain
    (identifier) @name)) @item

; --- variable declarations ---
(variable_declaration
  (variable_keyword) @context
  (var_entry
    (identifier) @name)) @item

(variable_declaration
  (variable_keyword) @context
  (var_entry
    (identifier_with_domain
      (identifier) @name))) @item

; --- equation declarations ---
(equation_declaration
  (equation_keyword) @context
  (eq_entry
    (identifier) @name)) @item

(equation_declaration
  (equation_keyword) @context
  (eq_entry
    (identifier_with_domain
      (identifier) @name))) @item

; --- equation definitions ---
; The leading `..` operator follows the name in parse-tree order, so the
; @context capture comes after @name in the pattern below.
(equation_definition
  name: (identifier) @name
  (equation_definition_op) @context) @item

(equation_definition
  name: (identifier_with_domain
    (identifier) @name)
  (equation_definition_op) @context) @item

; --- model declarations ---
(model_declaration
  (model_keyword) @context
  (model_entry
    (identifier) @name)) @item

; --- alias / acronym declarations ---
(alias_declaration
  (alias_keyword) @context
  (identifier) @name) @item

(acronym_declaration
  (acronym_keyword) @context
  (identifier) @name) @item

; --- solve statements ---
(solve_statement
  (solve_keyword) @context
  model: (identifier) @name) @item
