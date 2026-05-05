* Transportation Problem — canonical GAMS example
* Adapted from the GAMS Model Library

$title transport

sets
   i 'canning plants' / seattle, san-diego /
   j 'markets'        / new-york, chicago, topeka / ;

parameters
   a(i) 'capacity of plant i in cases'
        / seattle    350
          san-diego  600 /

   b(j) 'demand at market j in cases'
        / new-york   325
          chicago    300
          topeka     275 / ;

table d(i,j) 'distance in thousands of miles'
              new-york   chicago   topeka
seattle        2.5        1.7      1.8
san-diego      2.5        1.8      1.4 ;

scalar f 'freight in dollars per case per thousand miles' / 90 / ;

parameter c(i,j) 'transport cost in thousands of dollars per case' ;
c(i,j) = f * d(i,j) / 1000 ;

variables
   x(i,j) 'shipment quantities in cases'
   z      'total transportation costs in thousands of dollars' ;

positive variable x ;

equations
   cost        'define objective function'
   supply(i)   'observe supply limit at plant i'
   demand(j)   'satisfy demand at market j' ;

cost..        z =E= sum((i,j), c(i,j)*x(i,j)) ;
supply(i)..   sum(j, x(i,j))  =L=  a(i) ;
demand(j)..   sum(i, x(i,j))  =G=  b(j) ;

model transport / all / ;

solve transport using lp minimizing z ;

display x.l, x.m ;
