# test data for pcp features: create using rake db:seed:pcp_seed

a1 = Account.find( 1 )
puts "Using Account: #{a1.name}"

pc = PcpCategory.where( 'label LIKE ?', 'COM Document%' ).first
if pc.nil? then 
  pc = PcpCategory.new
  pc.p_group = Group.where( code: 'COM' ).first
  pc.c_group = Group.where( code: 'DVE' ).first
  pc.p_owner = a1
  pc.c_owner = a1
  pc.label = 'COM Document Reviews by DVE'
  pc.save!
  puts "New PCP Category created"
end

ps = PcpSubject.where( title: 'Typical HMI' ).first
if ps.nil? then
  ps = PcpSubject.new
  ps.pcp_category = pc
  ps.p_owner_id = a1.id
  ps.title = 'Typical HMI'
  ps.project_doc_id = '1874C-13SC-NN-0003'
  ps.report_doc_id = '1874C-13SC-NN-0003-OCS'
  ps.save!
  puts "New PCP Subject created"
end

s0 = ps.pcp_steps.where( step_no: 0 ).first
if s0.nil? then
  s0 = PcpStep.new
  s0.pcp_subject = ps
  s0.step_no = 0
  s0.subject_version = 'Rev.0'
  s0.report_version = 'Rev.0'
  s0.save!
  puts "PCP Step 0 created"
end

s1 = ps.pcp_steps.where( step_no: 1 ).first
if s1.nil? then
  s1 = ps.pcp_steps.create
  s1.create_release_from( s0, a1 )
  s0.save
  s1.save
  puts "PCP Step 1 created"
end

i09 = ps.pcp_items.where( seqno: 9 ).first
if i09.nil? then
  i09 = PcpItem.new
  i09.pcp_subject = ps
  i09.pcp_step = s1
  i09.seqno = 9
  i09.reference = 'General'
  i09.author = 'ADE/E42'
  i09.description = 'There shall be an Alarm Banner either on the top or bottom to display last three active alarms'
  i09.pub_assmt = nil
  i09.new_assmt = 0
  i09.assessment = 0
  i09.save
  puts 'Item 09 created'
end

i10 = ps.pcp_items.where( seqno: 10 ).first
if i10.nil? then
  i10 = PcpItem.new
  i10.pcp_subject = ps
  i10.pcp_step = s1
  i10.seqno = 10
  i10.reference = 'General'
  i10.author = 'ADE/E42'
  i10.description = 'There shall be a General Banner either at top or bottom to display Date, Time, Communication Status and a few essential parameters.'
  i10.pub_assmt = nil
  i10.new_assmt = 0
  i10.assessment = 0
  i10.save
  puts 'Item 10 created'
end