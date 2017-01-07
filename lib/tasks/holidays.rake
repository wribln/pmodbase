#lib/tasks/import.rake
desc 'Imports a CSV file with holiday information'
# usage: usage: rake db:seed:holidays[<code>,<col_sep>]
#
# need to use seed technique as holidays_XXX.csv uses codes
# and not IDs: this seed module translates these codes to IDs
#
require 'csv'

task :holidays, [ :code, :col_sep ] => :environment do |tasks, args|
  usage = 'usage: rake db:seed:holidays[<code>,<col_sep>]'
  args.with_defaults col_sep: ';'

  if args[ :code ].nil?
    puts usage
    next
  else
    country_code = args[ :code ].upcase
    filename = "holidays_#{ country_code }.csv"
  end

  h = nil
  row_no = 1 # include header row for easier reference
  bad_rows = 0
  good_rows = 0
  ignored = 0
  
  puts
  puts "Loading Holidays from db/std_csv/#{ filename }"

  country_name = CountryName.find_by_code( country_code )
  if country_name.nil?
    puts "> country_code '#{ country_code }' not found in CountryName table."
    next
  else
    country_id = country_name.id
  end
  
  CSV.foreach(File.join(Rails.root, 'db', 'std_csv', filename ), 
    col_sep: args[ :col_sep  ], headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|
  
    row_no += 1
    with_errors = false
  
    if row[ 'country_name' ].nil? then
      puts "\n> required country_name not specified"
      with_errors = true
    elsif row[ 'country_name' ] != country_code
      puts "\n> value '#{ row[ 'country_name' ] }' in column 'country_name' does not match requested country code '#{ country_code}'"
      with_errors = true
    end
  
    if row[ 'region_name' ].nil? then
      region_id = nil
    else
      region_name = RegionName.find_by_code( row[ 'region_name' ])
      if region_name.nil? then
        puts "> region_name #{ row[ 'region_name' ]} not found in RegionName table"
        with_errors = true
      else
        region_id = region_name.id
      end
    end
  
    unless with_errors then
      h = Holiday.new
      h.country_name_id = country_id
      h.region_name_id = region_id
      h.date_from = row[ 'date_from' ]
      h.date_until = row[ 'date_until' ]
      h.description = row[ 'description' ]
      h.work = row[ 'work' ] unless row[ 'work' ].nil?
      if h.work < 0 then
        ignored += 1
      else
        h.save
        unless h.errors.empty? then
          h.errors.full_messages.each { |m| puts m }
          with_errors = true
        else
          good_rows += 1
        end
      end
    end
  
    if with_errors then
      bad_rows += 1
      puts row.inspect
      puts ">>> bad row #{ row_no } not added"
      puts
    end
    print '.'
  end
  puts
  puts "Seed holidays completed:"
  puts "#{ good_rows } rows added"
  puts "#{ ignored } rows ignored (work < 0)"
  puts "#{ bad_rows } rows skipped due to errors."

end
