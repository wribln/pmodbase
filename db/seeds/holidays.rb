# - - - - - - - - - - Seed Holidays using holidays.csv
#
# need to use seed technique as holidays.csv uses codes
# and not IDs: this seed module translates these codes
# to IDs
#
require 'csv'

h = nil
row_no = 1 # include header row for easier reference
bad_rows = 0
good_rows = 0
ignored = 0

puts
puts 'Loading Holidays from db/std_csv/holidays.csv'

CSV.foreach(File.join(Rails.root, 'db', 'std_csv', 'holidays.csv' ), 
  col_sep: ';', headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|

  row_no += 1
  with_errors = false

  if row[ 'country_name' ].nil? then
    puts '> required country_name not specified'
    with_errors = true
  else
    country_name = CountryName.find_by_code( row[ 'country_name' ])
    if country_name.nil? then
      puts "> country_name #{ country_name } not found in CountyName table"
      with_errors = true
    else
      country_id = country_name.id
    end
  end

  if row[ 'region_name' ].nil? then
    region_id = nil
  else
    region_name = RegionName.find_by_code( row[ 'region_name' ])
    if region_name.nil? then
      puts "> region_name #{ region_name } not found in RegionName table"
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
    puts ">>> bad row #{ row_no} not added"
    puts
  end
  print '.'
end
puts
puts "Seed holidays completed:"
puts "#{ good_rows } rows added"
puts "#{ ignored } rows ignored (work < 0)"
puts "#{ bad_rows } rows skipped due to errors."