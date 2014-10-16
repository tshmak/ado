*! 1.0.0  10nov1998  Jeroen Weesie/ICS         STB-50 dm68
program define listblck
   version 6
   local dwidth : set display linesize

   syntax [varlist] [if] [in], [Repeat(int 0) Width(int `dwidth') noObs noLabel]

   * adjust width for displaying the observation numbers
   if "`obs'" == "" {
      local replen 3
   } 
   else {
      local obs noobs
      local replen -2
   }   
   
   * repvar = list of repeated variables
   * replen = total display width of repeated variables
   tokenize `varlist'
   local i 1
   while `i' <= `repeat' {
      local repvar "`repvar' `1'"
      widthvar `1'
      local replen = `replen' + 2 + r(width)
      local i = `i'+1
      mac shift
   }
      
   local vlen  `replen'
   local vlist `repvar'
   
   while "`1'" ~= "" {
      * ensured that at least one non-repeated variable is displayed!
      widthvar `1'
      local len1 = r(width)
      if `vlen' + 2 + `len1' + 1 >= `dwidth' {
         * display block   
         * di in gr _dup(`vlen') "-"
         list `vlist' `in' `if', nodisplay `obs' `label'
         
         * start new block
         local vlist "`repvar' `1'"
         local vlen = `replen' + 2 + `len1' 
      }
      else { 
         * add `1' to vlist    
         local vlist "`vlist' `1'"
         local vlen = `vlen' + 2 + `len1'
      }
      mac shift
   }
   
   * don't forget to display relast block
   if "`vlist'" ~= "" {
      *di in gr _dup(`vlen') "-"
      list `vlist' `in' `if', nodisplay `obs' `label'
   } 
     
   * clear S_* macros
   global S_1
end

program define widthvar, rclass 
   args v
   local f : format `v'
   local x : display `f' (`v'[1])
   return scalar width = length("`x'")
end   
exit

* code for version 5
* returns in S_1 the display width of a variable in list-output
program define widthvar
   args var vlab 

   local fmt : format `var'   
   local pf = substr("`fmt'",-1,1) /* last char of display format */
   
   if "`pf'" == "s" {
      * string    
      local len1 = substr("`fmt'",2,length("`fmt'")-2)    
   }             
   else if "`pf'" == "d" {
      * date, determine display width of "31 December 1960"
      local d : display `fmt' 365
      local len1 = length("`d'")
   }                
   else {
      * numeric variable
      local pp = index("`fmt'", ".")
      if `pp' > 0 {
         local len1 = substr("`fmt'",2,`pp'-2)  
      }
      else local len1 = substr("`fmt'",2,length("`fmt'")-2)    
        
      if "`vlab'" ~= "" {
         * width is at least 8 if value-labeled
         local vl : value label `var'
         if "`vl'" ~= "" { local len1 = max(8,`len1') }   
      }  
   }
   *global S_1 = max(length("`var'"), `len1')
   global S_1 `len1'   
end        
exit

Description

list-like command that repeats list's with blocks of variables rather
than wrapping lines or using "display" mode. If the option -repeate- 
is specified, the first k variable in varlist are repeated in each 
block.

Assumptions:
  list leaves one space after observation numbers
  list leaves 2 space between variables 
  list does not widen columns for long variables names
