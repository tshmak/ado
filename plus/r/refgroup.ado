*! version 1.1 -- 2/15/03 -- pbe
*! version 1.0 -- 8/14/02 -- pbe
*  char var[omit] grpnum
program define refgroup
version 7.0
  args var refgrp
  quietly summarize `var'
  if `refgrp' < r(min) | `refgrp' > r(max) {
    display as err "reference group value out of range"
    exit
  }
  char `var'[omit] `refgrp'
  display as txt "The reference group for `var' has been set to `refgrp'."
  display
end
