# - - - - - - - - - - Seed GlossaryItems using glossary.csv
#
# need to use seed technique as glossary_items.csv uses codes
# and not IDs: this seed module translates these codes to IDs
#
require 'csv'

gi = nil
ri = nil
row_no = 1 # include header row for easier reference
bad_rows = 0
good_rows = 0

puts

CSV.foreach(File.join(Rails.root, 'db', 'std_csv', 'glossary.csv' ), 
  col_sep: ';', headers: true, skip_blanks: true, encoding: 'UTF-8' ) do |row|

  row_no += 1
  with_errors = false

  if row[ 'reference_code' ].nil? then
    puts '> required reference_code not specified'
    with_errors = true
  else
    reference = Reference.find_by_code( row[ 'reference_code' ])
    if reference.nil? then
      puts '> reference_code not found in Reference table'
      with_errors = true
    else
      ri = reference.id
    end
  end

  unless with_errors then
    gi = GlossaryItem.new
    gi.term = row[ 'term' ]
    gi.code = row[ 'code' ]
    gi.description = row[ 'description' ]
    gi.reference_id = ri

    gi.save
    unless gi.errors.empty? then
      gi.errors.full_messages.each { |m| puts m }
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

end

puts "Seed glossary_items completed:"
puts "#{ good_rows } rows added"
puts "#{ bad_rows } rows skipped due to errors."
puts