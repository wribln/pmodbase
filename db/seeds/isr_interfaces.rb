# - - - - - - - - - - Seed ISR records using isr_interfaces.csv
#
# need to use seed technique as isr_interfaces.csv uses codes
# for groups and not IDs: this seed module translates these codes
# to IDs; must run AFTER having added the groups to the database!
#
# First column is rt (for RecordType), must be IF (for Interface)
# or IA (for Interface Agreement).
#
# IA uses only l_group, p_group, and desc (as def_text)
#
require 'csv'

h = nil
row_no = 1 # include header row for easier reference
bad_rows = 0
if_added = 0
ia_added = 0
last_if = nil
ia_no = nil

puts
puts 'Loading ISR Interfaces from db/std_csv/isr_interfaces.csv'

CSV.foreach(File.join(Rails.root, 'db', 'std_csv', 'isr_interfaces.csv' ), 
  col_sep: ';', headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|

  row_no += 1
  with_errors = false

  # determine record type

  if row[ 'rt' ].nil? then
    puts '> required rt not specified'
    with_errors = true
  elsif row[ 'rt' ] == 'IF' then
    last_if = nil
  elsif row[ 'rt' ] == 'IA' then
    if last_if.nil? then
      puts '> first row must be IF type record.'
      with_errors = true
    end
  else
    puts '> first column must be IF or IA.'
    with_errors = true
  end

  unless with_errors then
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
  end

  unless with_errors then
    if last_if.nil? then
      h = IsrInterface.new
      h.l_group_id = l_group_id
      h.p_group_id = p_group_id
      h.title = row[ 'title' ]
      h.desc = row[ 'desc' ]
      h.safety_related = row[ 'safety_related' ]
      h.if_level = row[ 'if_level' ]
    else
      h = last_if.isr_agreements.build
      h.l_group_id = l_group_id
      h.p_group_id = p_group_id
      h.def_text = row[ 'desc' ]
      ia_no += 1
      h.ia_no = ia_no
      h.prepare_revision( 0 )
      h.current_task = 1 # skip status 0
    end
    h.save
    unless h.errors.empty? then
      h.errors.full_messages.each { |m| puts m }
      with_errors = true
    else
      if last_if.nil? then
        if_added += 1
        last_if = h
        ia_no = 0
      else
        ia_added += 1
        ia_no += 1
      end
    end
  end

  if with_errors then
    puts row.inspect
    puts ">>> bad row #{ row_no} not added"
    puts
  end
  print '.'
end
puts
puts "Seed isr_interfaces completed:"
puts "#{ if_added } Interfaces added"
puts "#{ ia_added } Interface Agreements added"
puts "#{ bad_rows } rows skipped due to errors."