# - - - - - - - - - - Seed location_codes using location_codes.csv
#
# need to use seed technique as location_codes.csv references back
# to own records (part_of_id)
#
require 'csv'

lc = nil
row_no = 1 # include header row for easier reference
bad_rows = 0
good_rows = 0
parts_rows = 0

puts
puts '>>> Loading Location Codes'

# loop 1 - read data w/o part_of

CSV.foreach( File.join( Rails.root, 'db', 'projects', @project, 'location_codes.csv' ), 
  col_sep: ';', headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|

  row_no += 1

  lc = LocationCode.new
  lc.code = row[ 'code' ]
  lc.label = row[ 'label' ]
  lc.loc_type = LocationCode.loc_type_from_label( row[ 'loc_type' ])
  lc.center_point = row[ 'center_point' ]
  lc.start_point = row[ 'start_point' ]
  lc.end_point = row[ 'end_point' ]
  lc.length = row[ 'length' ]
  lc.remarks = row[ 'remarks' ]
  unless lc.save
    lc.errors.full_messages.each{ |m| puts m }
    bad_rows += 1
    puts
    puts row.inspect
    puts ">>> bad row #{ row_no} not added"
    puts
  else
    good_rows += 1
  end
  print '.'
end

# loop 2 - process part_of - if any

CSV.foreach( File.join( Rails.root, 'db', 'projects', @project, 'location_codes.csv' ), 
  col_sep: ';', headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|

  unless row[ 'part_of' ].blank?
    parts_rows += 1
    rec_part = LocationCode.find_by_code( row[ 'part_of' ])
    if rec_part.nil? then
      puts "\n>>> Part of reference #{ row[ 'part_of' ]} for Location Code #{ row[ 'code' ]} not defined.\n"
    else
      rec_main = LocationCode.find_by_code( row[ 'code' ])
      if rec_main.nil? then
        puts "\n>>> Unable to find master record with #{ row[ 'code' ]} to update part of reference to #{ row[ 'part_of' ] }\n"
      else
        rec_main.update_attribute( :part_of_id, rec_part.id )
      end
    end
  end
  print '.'
end
puts
puts "Seed location_codes.csv completed for project/#{ @project }"
puts "#{ good_rows } rows added."
puts "#{ parts_rows } part_of references processed."
puts "#{ bad_rows } rows skipped due to errors."
puts
