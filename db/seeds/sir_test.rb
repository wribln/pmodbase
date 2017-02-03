# seeds for testing SIR Log

sl = SirLog.first
if sl.nil?

sl = SirLog.new
sl.code = "SL"
sl.label = 'Safety Log'
sl.owner_account = Account.find( 1 )
sl.archived = false
unless sl.save
  puts sl.errors.messages
  puts '>>> seed terminated - 1'
  exit
end

end

si = sl.sir_items.first
if si.nil?

si = sl.sir_items.build
si.group = Group.where( code: 'ADMIN' ).first
si.seqno = 1
si.label = 'Safety Issue #1'
unless si.save
  puts si.errors.messages
  puts '>>> seed terminated - 2'
  exit
end

end

se1 = si.sir_entries.first
if se1.nil?

se1 = si.sir_entries.build
se1.rec_type = 0
se1.group = Group.where( code: 'ISA' ).first
se1.description = 'Please reply to issue'

unless se1.save
  puts se1.errors.messages
  puts '>>> seed termianted - 3'
  exit
end

end