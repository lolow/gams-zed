* Control-block fixture — exercises the opaque-body block constructs:
* $onEcho / $onPut / $onEmbeddedCode (Python injection). Generic
* $ifthen / $elseIf / $else / $endif directives are also present here
* — they parse as ordinary $-directives via the extras path, NOT as
* structural blocks (see tree-sitter-gams scanner notes).

$set scenario base

* === (1) labelled $ifthen / $endif (just a sequence of directives) ===
$ifthen.cb set calibration
$setglobal mode 'calib'
$endif.cb

* === (2) $ifthen / $elseIf / $else / $endif chain ===
$ifthen %scenario% == base
$setglobal data 'data_base.gdx'
$ifthen.s2 set s2_override
$setglobal extra '%s2_override%'
$endif.s2
$elseIf %scenario% == high
$setglobal data 'data_high.gdx'
$else
$setglobal data 'data_default.gdx'
$endif

* === (3) $onEcho — body is opaque text ===
$onEcho > config.txt
mode=calib
solver=cplex
$offEcho

* === (4) $onPut — same opaque-body treatment ===
$onPut
header line one
header line two
$offPut

* === (5) $onEmbeddedCode python — body re-parsed by Python grammar ===
$onEmbeddedCode python:
import gams_magic
result = sum(range(10))
print(f"computed {result}")
$offEmbeddedCode

* === (6) Plain $-directives still work alongside the blocks ===
$gdxIn '%data%'
$loadDC i, p
$gdxOut

set i / a, b, c /;
parameter cost(i)
   / a 1, b 2, c 3 /;
