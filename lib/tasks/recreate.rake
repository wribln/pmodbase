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

  Rake::Task['db:seed:regions'].invoke
  puts '>>> db:seed:regions completed.'

  Rake::Task['db:seed:holidays'].invoke
  puts '>>> db:seed:holidays completed.'

  Rake::Task['db:seed:groups'].invoke
  puts '>>> db:seed:groups completed'

  Rake::Task['db:seed:cfr_relations'].invoke
  puts '>>> db:seed:cfr_relations completed'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/cfr_file_types.csv','CfrFileType')
  puts '>>> import cfr file types completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/cfr_records.csv','CfrRecord')
  puts '>>> import cfr records completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/glossary.csv','GlossaryItem')
  puts '>>> import glossary items completed.'
  
  #exit!

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/pmdb_abbreviations.csv','Abbreviation')
  puts '>>> import pmdb abbreviations completed.'

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/abbreviations.csv','Abbreviation')
  puts '>>> import other abbreviations completed.'

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

  Rake::Task['import'].reenable
  Rake::Task['import'].invoke('db/std_csv/hashtags.csv','Hashtag')
  puts '>>> import hash_tags completed.'
  puts
  puts '>>> NEXT: perform project specific seeds.'

end