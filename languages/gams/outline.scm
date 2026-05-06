; Symbol outline for GAMS.
;
; Each declared name becomes one outline item. The leading keyword
; (set/parameter/...) is captured as @context so it shows beside the
; symbol name in the outline tree.
;
; @item is scoped to the innermost ENTRY node (set_entry / param_entry
; / etc.) rather than the parent declaration. A single
; `parameter foo, bar, baz ;` line therefore produces three sibling
; outline items instead of one parent with two visually-nested
; children — Zed nests items by @item containment, and the parent
; declaration would contain every entry.
;
; Declaration entries hold the name in one of three shapes:
;   *_entry → name_with_macros                                (foo_%clt%)
;   *_entry → identifier_with_domain → identifier             (foo(i,j))
;   *_entry → identifier_with_domain → name_with_macros       (foo_%clt%(i,j))
; In every case the leading bare identifier is what we surface as @name.

; --- set declarations ---
(set_declaration
  (set_keyword) @context
  (set_entry
    (name_with_macros
      (identifier) @name)) @item)

(set_declaration
  (set_keyword) @context
  (set_entry
    (identifier_with_domain
      (identifier) @name)) @item)

(set_declaration
  (set_keyword) @context
  (set_entry
    (identifier_with_domain
      (name_with_macros
        (identifier) @name))) @item)

; --- parameter declarations ---
(parameter_declaration
  (parameter_keyword) @context
  (param_entry
    (name_with_macros
      (identifier) @name)) @item)

(parameter_declaration
  (parameter_keyword) @context
  (param_entry
    (identifier_with_domain
      (identifier) @name)) @item)

(parameter_declaration
  (parameter_keyword) @context
  (param_entry
    (identifier_with_domain
      (name_with_macros
        (identifier) @name))) @item)

; --- scalar declarations ---
(scalar_declaration
  (scalar_keyword) @context
  (scalar_entry
    (name_with_macros
      (identifier) @name)) @item)

; --- table declarations ---
; Table has a single name field directly on the declaration (no entry
; wrapper), so @item stays on the declaration node here.
(table_declaration
  (table_keyword) @context
  name: (identifier) @name) @item

(table_declaration
  (table_keyword) @context
  name: (identifier_with_domain
    (identifier) @name)) @item

(table_declaration
  (table_keyword) @context
  name: (identifier_with_domain
    (name_with_macros
      (identifier) @name))) @item

; --- variable declarations ---
(variable_declaration
  (variable_keyword) @context
  (var_entry
    (name_with_macros
      (identifier) @name)) @item)

(variable_declaration
  (variable_keyword) @context
  (var_entry
    (identifier_with_domain
      (identifier) @name)) @item)

(variable_declaration
  (variable_keyword) @context
  (var_entry
    (identifier_with_domain
      (name_with_macros
        (identifier) @name))) @item)

; --- equation declarations ---
(equation_declaration
  (equation_keyword) @context
  (eq_entry
    (name_with_macros
      (identifier) @name)) @item)

(equation_declaration
  (equation_keyword) @context
  (eq_entry
    (identifier_with_domain
      (identifier) @name)) @item)

(equation_declaration
  (equation_keyword) @context
  (eq_entry
    (identifier_with_domain
      (name_with_macros
        (identifier) @name))) @item)

; --- equation definitions ---
; Single-name; the `..` operator follows the name in parse-tree
; order, so the @context capture comes after @name in the pattern.
(equation_definition
  name: (identifier) @name
  (equation_definition_op) @context) @item

(equation_definition
  name: (identifier_with_domain
    (identifier) @name)
  (equation_definition_op) @context) @item

(equation_definition
  name: (name_with_macros
    (identifier) @name)
  (equation_definition_op) @context) @item

(equation_definition
  name: (identifier_with_domain
    (name_with_macros
      (identifier) @name))
  (equation_definition_op) @context) @item

; --- model declarations ---
(model_declaration
  (model_keyword) @context
  (model_entry
    (identifier) @name) @item)

; --- alias / acronym declarations ---
; Alias holds a parenthesised list of identifiers; each one is its
; own outline item so a `alias (a, b, c) ;` line yields three
; sibling entries.
(alias_declaration
  (alias_keyword) @context
  (identifier) @name @item)

(acronym_declaration
  (acronym_keyword) @context
  (identifier) @name @item)

; --- solve statements ---
(solve_statement
  (solve_keyword) @context
  model: (identifier) @name) @item
