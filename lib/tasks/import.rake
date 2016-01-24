#lib/tasks/import.rake
desc 'Imports a CSV file into an ActiveRecord table'
# usage: rake import[model_data.csv, model_name]
# where: model_data.csv contains a header with the column names
require 'csv'
task :import, [ :filename, :model, :col_sep ] => :environment do |tasks, args|
  usage = 'usage: rake import[<model_data.csv>,<ModelName>,<col_sep>]'
  args.with_defaults col_sep: ';'

  if args[ :filename ].nil?
    puts usage
    next
  end

  if args[ :model ].nil?
    puts usage
    next
  end

  puts "Importing from file:       #{ args[ :filename ]}"
  puts "          to model:        #{ args[ :model    ]}"
  puts "    using separator:      '#{ args[ :col_sep  ]}'"

  lines_processed = 1 # including header row
  records_added = 0

  CSV.foreach( args[ :filename ], headers: true, encoding: 'UTF-8', col_sep: args[ :col_sep  ]) do |row|
    lines_processed += 1
    r = Module.const_get( args[ :model ]).create( row.to_hash )
    if r.valid?
      r.save
      records_added += 1
    else
      puts ">>> Line #{ lines_processed } errors: #{ r.errors.full_messages }"
    end
  end
  
  puts "Number of lines processed: #{ lines_processed }"
  puts "Number of records added:   #{ records_added }"
  puts "Final number of records:   #{ Module.const_get( args[ :model ]).count }" 

end