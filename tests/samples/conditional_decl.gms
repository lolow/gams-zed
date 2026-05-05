* Real-world conditional-declaration patterns.
* Inspired by the WITCH integrated assessment model.

$set phase eqs
$set clt cb_high

equations
$ifthen %phase%=='eqs'
   eqbunkfuel_sea_%clt%
   eq_ships1_%clt%
   eq_depr_k_ship_%clt%
$if not set bunk_sea_fuel_free_decline eq_bunkfuel_fluc1_%clt%
*eq_bunkfuel_fluc1j_%clt%
$if not set bunk_sea_fuel_free_adoption eq_bunkfuel_fluc2_%clt%
$if set imo_measure eqq_imo_levy_%clt%
   eq_qemi_bunk_sea_%clt%
$if set imo_target eq_qemi_bunk_sea_imo_%clt%
$elseif %phase%=='eql'
   eqbunkfuel_sea_%clt%
   eqbunk_sea4_%clt%
$endif
;

* Set names with %macro% inside parse via name_with_macros:
*   identifier `eqbunkfuel_sea_` + macro_ref `%clt%`.
* The %clt% segment still highlights as @constant.macro even when
* nested inside a declaration name.
