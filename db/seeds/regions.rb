# - - - - - - - - - - Countries

puts
puts 'Loading Countries'

CountryName.create code: 'ARE', label: 'United Arab Emirates (favoured)'
CountryName.create code: 'ARG', label: 'Argentina'
CountryName.create code: 'AUS', label: 'Australia'
CountryName.create code: 'AUT', label: 'Austria'
CountryName.create code: 'BEL', label: 'Belgium'
CountryName.create code: 'BOL', label: 'Bolivia (Plurinational State of)'
CountryName.create code: 'BRA', label: 'Brazil'
CountryName.create code: 'CHN', label: 'China'
CountryName.create code: 'CZE', label: 'Czech Republic'
CountryName.create code: 'DNK', label: 'Denmark'
CountryName.create code: 'DOM', label: 'Dominican Republic'
CountryName.create code: 'ESP', label: 'Spain'
CountryName.create code: 'FIN', label: 'Finland'
CountryName.create code: 'FRA', label: 'France'
CountryName.create code: 'GER', label: 'Germany'
CountryName.create code: 'IND', label: 'India'
CountryName.create code: 'ISR', label: 'Israel'
CountryName.create code: 'KSA', label: 'Saudi Arabia (Kingdom of)'
CountryName.create code: 'MEX', label: 'Mexico'
CountryName.create code: 'NLD', label: 'Netherlands'
CountryName.create code: 'NOR', label: 'Norway'
CountryName.create code: 'POL', label: 'Poland'
CountryName.create code: 'PRT', label: 'Portugal'
CountryName.create code: 'QAT', label: 'Qatar'
CountryName.create code: 'SGP', label: 'Singapore'
CountryName.create code: 'SWE', label: 'Sweden'
CountryName.create code: 'THA', label: 'Thailand'
CountryName.create code: 'UAE', label: 'United Arab Emirates (preferred: ARE)'
CountryName.create code: 'USA', label: 'United States of America'

# - - - - - - - - - - States in Germany

puts
puts 'Loading Regions'

CountryName.transaction do
  cn = CountryName.lock( true ).find_by!( code: 'GER' )
  RegionName.create country_name_id: cn.id, code: 'BW', label: 'Baden-Württemberg'     
  RegionName.create country_name_id: cn.id, code: 'BY', label: 'Bayern'                
  RegionName.create country_name_id: cn.id, code: 'BE', label: 'Berlin'                
  RegionName.create country_name_id: cn.id, code: 'BB', label: 'Brandenburg'           
  RegionName.create country_name_id: cn.id, code: 'HB', label: 'Bremen'                
  RegionName.create country_name_id: cn.id, code: 'HH', label: 'Hamburg'               
  RegionName.create country_name_id: cn.id, code: 'HE', label: 'Hessen'                
  RegionName.create country_name_id: cn.id, code: 'MV', label: 'Mecklenburg-Vorpommern'
  RegionName.create country_name_id: cn.id, code: 'NI', label: 'Niedersachsen'         
  RegionName.create country_name_id: cn.id, code: 'NW', label: 'Nordrhein-Westfalen'   
  RegionName.create country_name_id: cn.id, code: 'RP', label: 'Rheinland-Pfalz'       
  RegionName.create country_name_id: cn.id, code: 'SL', label: 'Saarland'              
  RegionName.create country_name_id: cn.id, code: 'SN', label: 'Sachsen'               
  RegionName.create country_name_id: cn.id, code: 'ST', label: 'Sachsen-Anhalt'        
  RegionName.create country_name_id: cn.id, code: 'SH', label: 'Schleswig-Holstein'    
  RegionName.create country_name_id: cn.id, code: 'TH', label: 'Thüringen'             
end
