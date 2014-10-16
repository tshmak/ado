*! version 2.0.1  04jun2013
*! Sergiy Radyakin 2007-2013
*! 64af3dc6-d21c-4874-a990-730419363021


program define spss

	version 9.2

	if (c(os)!="Windows") {
          display as error "Incompatible platform. This program is only available in MS Windows"
          error 702
	}

	gettoken subcmd 0 : 0

  if `"`subcmd'"'=="" {
    UseSpss
  }
  else if (`"`subcmd'"' == "about") {
    mata usespss_about()
  }
  else if inlist(`"`subcmd'"',   "get","use","load","open","read","import") {

    capture syntax anything [,clear]
    if (!_rc) {
      local file `anything'
      capture confirm file "`file'"
      if (!_rc) {
        UseSpss "`file'" , `clear'
      }
      else {
        // ???
        // UseSpss `0' , `clear'
        error 601
      }
    }
    else {
      syntax 
      db usespss
    }
  }
  else if (`"`subcmd'"' == "des") | (`"`subcmd'"' == "describe") {
    DesSpss `0'
  }
  else if (`"`subcmd'"' == "webuse") {
    WebUseSpss `0'
  }
  else if (`"`subcmd'"' == "examples") {
    ExamplesSpss
  }
  else if (`"`subcmd'"' == "convert") {
    UseSpssConvert `0'
  }
  else {
    display as error "Unknown subcommand: `subcmd'"
  }

end

program define UseSpssConvert

	version 9.2

	syntax , from(string) to(string) [dofile(string)]

        // todo: add -replace- option to above

        mata usespss_convert()
end

program define UseSpss

  	version 9.2

	if (`"`0'"'=="") {
		db usespss
		exit
	}
  
	syntax anything [, clear]

	local anything `anything'
	confirm file `"`anything'"'

	mata usespss_welcome()
  
	mata st_local("input",`"""' + usespss_makepathabs(st_local("anything")) + `"""')
 
	tempfile stata

	UseSpssConvert, from(`"`input'"') to(`"`stata'"')
  
	use `"`stata'"', `clear'
  
	ds

	mata usespss_write_renames()
	mata usespss_check_for_dates()

end

program define WebUseSpss

        version 9.2
        syntax anything, [clear]
      
        local there `anything'
        tempfile here
        copy `"`there'"' `"`here'"'
        sleep 500
        display "Downloaded"
        spss use `"`here'"', `clear'
        global S_FN `"`there'"'

        
        // e.g. here:
        // http://wps.ablongman.com/ab_george_windows_5/25/6413/1641811.cw/index.html

end

program define DesSpss, rclass

        version 9.2

	syntax using/

	capture confirm file `"`using'"'
        if _rc {
          display as error "Error! SPSS file does not exist"
          error(601)
        }

	tempfile statafile dofile	

	quietly UseSpssConvert, from(`"`using'"') to(`"`statafile'"') dofile(`"`dofile'"')

	capture confirm file `"`dofile'"'
	if _rc!=0 {
		display as error `"Couldn't describe file `using'"'
		error 101
	}

	quietly do `"`dofile'"'

	// ------- legacy code follows -------------------------------------------------------------

     if `"`finished'"'!="101" {

       display as error "Something went wrong while analysing the file"
       display as error "Most probably the file is not in SPSS *.sav format"
       display as error "Please examine the diagnostic messages above"
       error 9999
       
     }

     display as text "DESSPSS Report"
     display as text `"=============="'

     display as text "SPSS System file: " as result `"`macval(using)'"'
     return local filename `"`macval(using)'"'

     display as text "Created (date): " as result `"`SPSS_creation_date'"'
     return local date `"`SPSS_creation_date'"'

     display as text "Created (time): " as result `"`SPSS_creation_time'"'
     return local time `"`SPSS_creation_time'"'

     display as text "SPSS product: " as result _asis `"`macval(SPSS_product)'"'
     return local product `"`=trim(`"`macval(SPSS_product)'"')'"'

     display as text "File label (if present): " as result `"`SPSS_file_label'"'

     display as text "File size (as stored on disk): " as result `"`SPSS_file_size' bytes"'
     return scalar filesize =`SPSS_file_size'

     display as text "Data size: " as result `"`SPSS_data_size' bytes"'
     return scalar datasize = `SPSS_data_size'

     if `SPSS_file_compressed'==-1 {
       display as text "Data stored in compressed format"
       return scalar compressed=1
     }
     else {
       display as text "Data stored in not compressed format"
       return scalar compressed=0
     }

     if (`SPSS_bo'==-1) {
       display as text "This file is likely to originate from a Windows platform (LoHi byte order)"
       return local byte_order="LoHi"
     }
     else {
       display as text "This file is likely to originate from a Mac/Unix platform (HiLo byte order)"
       return local byte_order="HiLo"
     }

     display

     display as text "Number of cases (observations): " as result `"`SPSS_case_count'"'
     return scalar N = `SPSS_case_count'

     display as text "Number of variables: " as result `"`SPSS_var_count'"'
     return scalar k = `SPSS_var_count'

     display as text "Case size: " as result `"`=`SPSS_case_size'*8' bytes"'
     return scalar width = `=`SPSS_case_size'*8'

     display as text "----------------------------------------------------------------------"

     display
     display "Variables:"
     display

        //The code below is borrowed from Stata's standard describe command

                        local wid = 2
                        local n : list sizeof SPSS_varlist
                        if `n'==0 {
                                exit
                        }

                        foreach x of local SPSS_varlist {
                                local wid = max(`wid', length(`"`x'"'))
                        }

                        local wid = `wid' + 2
                        local cols = int((`c(linesize)'+1)/`wid')
                        if `cols' < 2 {
                                foreach x of local `SPSS_varlist' {
                                        di as txt `col' `"`x'"'
                                }
                                exit
                        }
                        local lines = `n'/`cols'
                        local lines = int(cond(`lines'>int(`lines'), `lines'+1, `lines'))
                        forvalues i=1(1)`lines' {
                                local top = min((`cols')*`lines'+`i', `n')
                                local col = 1
                                forvalues j=`i'(`lines')`top' {
                                        local x : word `j' of `SPSS_varlist'
                                        di as txt _column(`col') "`x'" _c
                                        local col = `col' + `wid'
                                }
                                di as txt
                        }
         return local varlist `SPSS_varlist'

end

program define ExamplesAblongman5
    local datasets "ANXIETY.SAV DIVORCE.SAV EX07-3.SAV EX11-8.SAV EX11-9.SAV EX14-6.SAV EX14-7.SAV EX15-4.SAV EX15-5.SAV EX16-4.SAV EX23-5.SAV GRADECOL.SAV GRADEROW.SAV GRADES.SAV GRADUATE.SAV HELPING1.SAV HELPING2.SAV HELPING3.SAV VCR.SAV ex24-3%2024-4%2024-5.sav grades-mds.sav grades-mds2.sav"
    display `"{text}Example data online from the book by Darren George and Paul Mallery"'
    display `"{browse "http://wps.ablongman.com/ab_george_windows_5/25/6413/1641811.cw/index.html":SPSS for Windows Step by Step: A Simple Guide and Reference, 12.0 Update, 5e.}"'
    foreach data in `datasets' {
      display `"{stata "spss webuse http://wps.ablongman.com/wps/media/objects/1603/1641811/`data'":`data'}"'
    }
    display ""
end

program define ExamplesAblongman12
    local datasets "anxiety.sav divorce.sav divorce-studentversion.sav EX04-6-studentversion.sav EX07-3.SAV EX11-8.SAV EX11-9.SAV EX14-6.SAV EX14-7.SAV EX15-5.SAV EX15-6.SAV EX16-4.SAV EX18-10-studentversion.sav EX18-13-studentversion.sav EX18-1-studentversion.sav EX18-2-studentversion.sav EX18-3-studentversion.sav EX18-4-studentversion.sav EX18-5-studentversion.sav EX18-6-studentversion.sav EX18-7-studentversion.sav EX18-8-studentversion.sav EX18-9-studentversion.sav EX23-5.SAV ex24-3%2024-4%2024-5.sav GRADECOL.SAV GRADEROW.SAV grades.sav gradescol.sav grades-mds.sav grades-mds2.sav gradesrow.sav graduate.sav helping1.sav helping2.sav helping2a.sav helping3.sav helping3-studentversion.sav vcr.sav"
    display `"{text}Example data online from the book by Darren George and Paul Mallery"'
    display `"{browse "http://wps.ablongman.com/ab_george_windows_5/25/6413/1641811.cw/index.html":Companion Website for IBM SPSS Statistics 19 Step by Step: A Simple Guide and Reference, 12e .}"'
    foreach data in `datasets' {
      display `"{stata "spss webuse http://wps.ablongman.com/wps/media/objects/13726/14056073/Data%20Sets/Website%20Resources/Data%20Files/`data'":`data'}"'
    }
    display ""
end

program define ExamplesAmm
    local datasets "Buying.sav Cntry15.sav Country.sav Electric.sav Endorph.sav gss.sav Gssft.sav Iq.sav Lambda.sav Renal.sav Runs.sav Salary.sav Schools.sav Simul.sav"
    display `"{text}Example data online from the book byCraig A. Mertler and Rachel A. Vannatta"'
    display `"{browse "http://edhd.bgsu.edu/amm/datasets.html":Advanced and Multivariate Statistical Methods: Practical Application and Interpretation 3e.}"'
    foreach data in `datasets' {
      display `"{stata "spss webuse http://edhd.bgsu.edu/amm/SPSS%20Data/`data'":`data'}"'
    }
    display ""
end

program define ExamplesSpss
    ExamplesAblongman5
    ExamplesAblongman12
    ExamplesAmm
end

program define ExamplePages
   display "ToBeImplemented"
   http://edhd.bgsu.edu/amm/datasets.html
  /*
   http://www.ats.ucla.edu/stat/spss/examples/chp/chpspss_dl.htm
   http://calcnet.mth.cmich.edu/org/spss/Prjs_DataSets.htm
   http://core.ecu.edu/psyc/wuenschk/spss/spss-Data.htm
   http://www.personal.psu.edu/meh11/SPSS_DataSets/SPSS.htm
   http://staff.bath.ac.uk/pssiw/stats2/page16/page16.html

   http://www.uta.edu/faculty/story/DataSets.htm

   // =================ZIPPED =============================
   http://www3.norc.org/GSS+Website/Download/SPSS+Format/
   http://www.allenandunwin.com/spss/data_files.html ---- zipped
   http://www.sagepub.com/field3e/SPSSdata.htm ---- zipped
  */
end





// EOF
