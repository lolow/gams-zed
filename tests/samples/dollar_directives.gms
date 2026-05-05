* Compile-time directives, macros, and conditional compilation.
* Verifies that $-directives at column 0, $$-directives inline,
* and %macro% references all highlight as their dedicated scopes.

$title compile-time directives demo
$set scenario base
$setglobal solver cplex
$setlocal limit 1000

* Conditional compilation: pick one of two data sources. GAMS dollar
* directives must start in column 0 (or use $$ for the inline form).
$ifThen %scenario% == base
$include data_base.inc
$elseIf %scenario% == high
$include data_high.inc
$else
$include data_default.inc
$endif

* Listing-control toggles around a noisy block.
$onListing
$offSymList

set i / a, b, c /;
parameter cost(i)
   / a 100, b 200, c 300 /;

* Inline $$-form: directive inside another statement's region.
$$set rep_path "reports/%scenario%.gdx"

* GDX I/O directives (treated as opaque @keyword.directive lines).
$gdxIn input_%scenario%.gdx
$loadDC i, cost
$gdxOut

* Macro definition then reference.
$macro double(x) ((x)*(x))

scalar pi / 3.14 /;
scalar pi_sq;
pi_sq = double(pi) ;

* Quoted strings can hold macros — the surrounding string colours win
* (string injection deferred); verify the string still highlights.
display "scenario %scenario% solver %solver% complete";

$exit
