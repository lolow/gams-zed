* Minimal GAMS model — exercises the basic declaration / assignment /
* equation / solve forms with single-form coverage of each construct.

set i / a, b, c /;

scalar pi / 3.14 /;

parameter w(i)
   / a 1, b 2, c 3 /;

variables
   x(i)  'choice variable'
   z     'objective' ;

positive variable x ;

equations
   total          'sum of choices'
   capacity(i)    'per-element bound' ;

total..        z =E= sum(i, w(i) * x(i)) ;
capacity(i)..  x(i) =L= 10 ;

model hello / all / ;

solve hello using lp maximizing z ;

* Post-solve report loop demonstrating the `loop` keyword.
loop(i,
   display x.l(i) ;
);

display x.l, z.l ;
