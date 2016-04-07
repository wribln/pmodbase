# - - - - - - - - - - Seed groups using groups.csv
#
# need to use seed technique as groups.csv uses codes
# and not IDs: this seed module translates these codes
# to IDs
#
require 'csv'

g = nil
row_no = 1 # include header row for easier reference
bad_rows = 0
good_rows = 0

puts

CSV.foreach(File.join(Rails.root, 'db', 'std_csv', 'groups.csv' ), 
  col_sep: ';', headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|

  row_no += 1
  with_errors = false

  sub_group_of_id = row[ 'sub_group_of' ]
  unless sub_group_of_id.nil? then
    sub_group_of = Group.find_by_code( row[ 'sub_group_of' ])
    if sub_group_of.nil? then
      puts "> sub-group code not (yet?) found in group table: >#{ row[ 'sub_group_of' ]}<"
      with_errors = true
    else
      sub_group_of_id = sub_group_of.id
    end
  end

  unless with_errors then
    g = Group.new
    g.code = row[ 'code' ]
    g.label = row[ 'label' ]
    g.notes = row[ 'notes' ]
    g.group_category_id = row[ 'group_category_id' ]
    g.sub_group_of_id = sub_group_of_id
    g.participating = row[ 'participating' ]
    g.s_sender_code = row[ 's_sender_code' ]
    g.s_receiver_code = row[ 's_receiver_code' ]
    g.active = row[ 'active' ]
    g.standard = row[ 'standard' ]
    if g.save then
      good_rows += 1
    else
      g.errors.full_messages.each { |m| puts m }
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

puts "Seed groups completed:"
puts "#{ good_rows } rows added"
puts "#{ bad_rows } rows skipped due to errors."
puts