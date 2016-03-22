# - - - - - - - - - - Seed NetworkStops using network_stops.csv
#
# need to use seed technique as network_stops.csv uses codes
# to link to NetworkStations, NetworkLines, LocationCodes
#
require 'csv'

h = nil
row_no = 1 # include header row for easier reference
bad_rows = 0
good_rows = 0

puts

CSV.foreach(File.join(Rails.root, 'db', 'projects', 'dmr', 'network_stops.csv' ), 
  col_sep: ';', headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|

  row_no += 1
  with_errors = false

  if row[ 'network_station' ].nil? then
    puts '> required network_station not specified'
    with_errors = true
  else
    network_station = NetworkStation.find_by_code( row[ 'network_station' ])
    if network_station.nil? then
      puts '> network_station not found in NetworkStation table'
      with_errors = true
    else
      network_station_id = network_station.id
    end
  end

  if row[ 'network_line' ].nil? then
    puts '> required network_line not specified'
    with errors = true
  else
    network_line = NetworkLine.find_by_code( row[ 'network_line' ])
    if network_line.nil? then
      puts '> network_line not found in NetworkLine table'
      with_errors = true
    else
      network_line_id = network_line.id
    end
  end

  if row[ 'location_code' ].nil? then
    location_code_id = nil
  else
    location_code = LocationCode.find_by_code( row[ 'location_code' ])
    if location_code.nil? then
      puts '> location_code not found in LocationCode table'
      with_errors = true
    else
      location_code_id = location_code.id
    end
  end

  unless with_errors then
    s = NetworkStop.new
    s.network_station_id = network_station_id
    s.network_line_id = network_line_id
    s.location_code_id = location_code_id
    s.code = row[ 'code' ]
    s.note = row[ 'note' ]
    s.stop_no = row[ 'stop_no' ]
    s.save
    if s.errors.empty? then
      good_rows += 1
    else
      s.errors.full_messages.each { |m| puts m }
      with_errors = true
    end
  end

  if with_errors then
    bad_rows += 1
    puts row.inspect
    puts ">>> bad row #{ row_no} not added"
    puts
  end

end

puts "Seed location_codes.csv completed:"
puts "#{ good_rows } rows added"
puts "#{ bad_rows } rows skipped due to errors."
puts