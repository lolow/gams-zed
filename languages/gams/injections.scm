; Inject Python highlighting into the body of $onEmbeddedCode blocks.
;
;   $onEmbeddedCode python:
;     # this body parses as Python
;     for i in range(10):
;         print(i)
;   $offEmbeddedCode
;
; The grammar captures the body as `embedded_body`; this injection
; tells Zed to re-parse it with the Python tree-sitter grammar.
; Connect / GAMS-script bodies are also valid here but Python is
; overwhelmingly the most common — switching dynamically would
; require capturing the language hint after $onEmbeddedCode.

((embedded_body) @injection.content
 (#set! injection.language "python"))

; The bodies of $onEcho and $onPut are plain text destined for an
; external file. There's no language to inject; tree-sitter
; treating them as opaque content (no further highlight) is the
; right default.
