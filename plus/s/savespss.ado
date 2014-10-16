program define savespss
  version 10.0
  syntax [anything], [extmiss(string)]


  if (missing(`"`anything'"')) {
    mata savespss_about()
    db savespss
  }
  else { 
    mata savespss(`anything') 
  }
end

// eof
