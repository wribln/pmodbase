# - - - - - - - - - - Seed ISR records using isr_interfaces.csv
#
# need to use seed technique as isr_interfaces.csv uses codes
# for groups and not IDs: this seed module translates these codes
# to IDs; must run AFTER having added the groups to the database!
#
require 'csv'

h = nil
row_no = 1 # include header row for easier reference
bad_rows = 0
good_rows = 0

puts
puts 'Loading ISR Interfaces from db/std_csv/isr_interfaces.csv'

CSV.foreach(File.join(Rails.root, 'db', 'std_csv', 'isr_interfaces.csv' ), 
  col_sep: ';', headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|

  row_no += 1
  with_errors = false

  if row[ 'l_group' ].nil? then
    puts '> required l_group not specified'
    with_errors = true
  else
    l_group = Group.find_by_code( row[ 'l_group' ])
    if l_group.nil? then
      puts "> l_group #{ l_group } not found in Group table"
      with_errors = true
    else
      l_group_id = l_group.id
    end
  end

  if row[ 'p_group' ].nil? then
    puts '> required p_group not specified'
    with_errors = true
  else
    p_group = Group.find_by_code( row[ 'p_group' ])
    if p_group.nil? then
      puts "> p_group #{ p_group } not found in Group table"
      with_errors = true
    else
      p_group_id = p_group.id
    end
  end

  unless with_errors then
    h = IsrInterface.new
    h.l_group_id = l_group_id
    h.p_group_id = p_group_id
    h.title = row[ 'title' ]
    h.desc = row[ 'desc' ]
    h.safety_related = row[ 'safety_related' ]
    h.if_level = row[ 'if_level' ]
    h.save
    unless h.errors.empty? then
      h.errors.full_messages.each { |m| puts m }
      with_errors = true
    else
      good_rows += 1
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
puts "Seed isr_interfaces completed:"
puts "#{ good_rows } rows added"
puts "#{ bad_rows } rows skipped due to errors."