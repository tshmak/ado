
*! version 1.61.0 09jul2014 savespss by Sergiy Radyakin
*! saves data to SPSS system file (*.sav)
*! a11f515d-2e77-4c64-97e7-b42b70c7e742

program define savespss
  version 10.0
  
  display in red    "Error. You have installed -savespss- command from a wrong location."
  display in green  "Savespss has moved to SSC. Please uninstall this version and update your links"
  display in red    "Type: findit savespss in Stata's command prompt to install from correct location"
  display in yellow "If you have questions about older versions, kindly let me know. Sergiy Radyakin."
  error 6
end

// eof
