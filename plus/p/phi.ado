program define phi
version 2.1
*! This is version 1.0  01 August 1991
        if "%_2"=="" {
                di in red "invalid syntax -- see help phi"
                exit 198
        }
        mac def _varlist "req ex max(2)"
        mac def _in "opt"
        mac def _if "opt"
        mac def _options "*"
        parse "%_*"
        parse "%_varlist", parse(" ")
        ta %_1 %_2 %_if %_in, chi %_options
        mac def _en=_result(1)
        mac def _chi=_result(4)
        mac def _row=_result(2)
        mac def _col=_result(3)
if %_row==2 & %_col==2 {
di "phi = Cohen's w = fourfold point correlation =" %7.4f sqrt(%_chi/%_en) /*
 */ _sk(3) "phi-squared =" %7.4f %_chi/%_en
}
else {
di "Cramer's phi-prime = " %7.4f sqrt(%_chi/(%_en*(%_row-1))) _sk(5) /*
 */ "Cohen's w =" %7.4f sqrt(%_chi/%_en)
}
end
