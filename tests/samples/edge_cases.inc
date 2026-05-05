* Edge-case fixture for the GAMS Zed extension.
* Each section probes a specific lexical or syntactic corner that
* historically tripped the parser or the highlights queries.

* === (1) all three comment forms ==================================

* Column-1 line comment.

$ontext
A multi-line dollar block comment that contains a stray * inside,
plus a $-style directive-like word ($notADirective), and even what
looks like a closing marker but isn't ($offt0xt). The only thing
that closes the block is the real $offtext below.
$offtext

/* C-style block comment that also spans
   multiple lines and contains * stars * everywhere
   but no embedded closing markers (those would close it). */

* === (2) hyphenated set elements ==================================
* `san-diego` and `new-york` would fail with upstream's element_entry
* rule because identifier doesn't permit hyphens. The fork's
* element_entry alternates set_element / identifier.

set city / new-york, san-diego, los-angeles, topeka /;

* === (3) literal constants =======================================

scalar big       / inf /;
scalar tiny      / eps /;
scalar missing   / na  /;
scalar feasible  / yes /;

* === (4) suffix references ========================================
* Variable suffixes plus equation suffixes in one expression.

variable x(city) ;
equation balance(city) ;
balance(city)..  x.l(city) =E= x.up(city) - x.lo(city) + x.scale(city) ;

* === (5) equation slack / infeasibility suffixes (post-solve) =====

scalar total_infeas ;
total_infeas = sum(city, balance.infeas(city) + balance.slack(city)) ;

* === (6) range expansion in set literals ==========================

set t / t1 * t10 / ;
set yr / 2020 * 2030 / ;

* === (7) all relational operators in equation definitions =========

equations  e1, e2, e3, e4, e5 ;
e1.. x.l('topeka') =E= 0 ;
e2.. x.l('topeka') =L= 100 ;
e3.. x.l('topeka') =G= 0 ;
e4.. x.l('topeka') =N= 0 ;
e5.. x.l('topeka') =X= 0 ;

* === (8) MCP-style solve without minimizing/maximizing ============

model mcp_demo / e1, e2 / ;
solve mcp_demo using mcp ;

* === (9) inline $$-directive ======================================

set j / a, b, c /; $$exit

* === (10) macro reference in expression context ====================
* %limit% has been set earlier (e.g. via `$set limit 100`); a parameter
* assignment can pull it directly into a numeric position.

$set limit 100
scalar cap_value ;
cap_value = %limit% ;
