* Control-block fixture — exercises $ifthen / $endif pairing,
* nested labels, $onEcho, $onPut, $onEmbeddedCode (Python injection).

$set scenario base

* === (1) labelled $ifthen with matched $endif (no diagnostic) ===
$ifthen.cb set calibration
$setglobal mode 'calib'
$endif.cb

* === (2) $ifthen / $else / $endif with nested labelled block ===
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
