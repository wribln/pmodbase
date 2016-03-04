#lib/tasks/recreate.rake
desc 'This rebuilds the development database'
task :recreate => :environment do

  Rake::Task['db:drop'].invoke
  puts '>>> db:drop completed.'

  Rake::Task['db:create'].invoke
  puts '>>> db:create completed.'

  Rake::Task['db:migrate'].invoke
  puts '>>> db:migrate completed.'

  Rake::Task['db:seed'].invoke
  puts '>>> db:seed completed.'

  Rake::Task['db:seed:phases'].invoke
  puts '>>> db:seed:phases completed.'

#  Rake::Task['db:seed:regions'].invoke
#  puts '>>> db:seed:regions completed.'

#  Rake::Task['db:seed:holidays'].invoke
#  puts '>>> db:seed:holidays completed.'

  Rake::Task['import'].invoke('db/std_csv/references.csv','Reference')
  puts '>>> import references completed.'

#  Rake::Task['db:seed:glossary'].invoke
#  puts '>>> db:seed:glossary completed.'

#  Rake::Task['import'].reenable
#  Rake::Task['import'].invoke('db/std_csv/abbreviations.csv','Abbreviation')
#  puts '>>> import abbreviations completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/groups.csv','Group')
  puts '>>> import groups completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/standards_bodies.csv','StandardsBody')
  puts '>>> import standards_bodies completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/unit_names.csv','UnitName')
  puts '>>> import unit_names completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/dcc_codes.csv','DccCode')
  puts '>>> import dcc_codes completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/function_codes.csv','FunctionCode')
  puts '>>> import function_codes completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/service_codes.csv','ServiceCode')
  puts '>>> import service_codes completed.'

end