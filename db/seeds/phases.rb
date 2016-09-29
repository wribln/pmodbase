# - - - - - - - - - - Siemens phase standard

puts
puts '>>> Loading Siemens Phases'

SiemensPhase.create( code: '%PM010', label_p: 'Lead Management',          label_m: 'Go / No-Go decision' )
SiemensPhase.create( code: '%PM020', label_p: 'Opportunity Development',  label_m: 'Bid decision' )
SiemensPhase.create( code: '%PM040', label_p: 'Bid Preparation',          label_m: 'Bid approval' )
SiemensPhase.create( code: '%PM070', label_p: 'Contract Negotiation',     label_m: 'Project won / lost' )
SiemensPhase.create( code: '%PM080', label_p: 'Project Handover',         label_m: 'Start of project' )
SiemensPhase.create( code: '%PM100', label_p: 'Project opening & clarification', label_m: 'Order receipt clarified' )
SiemensPhase.create( code: '%PM200', label_p: 'Detailed planning',        label_m: 'Approval of detailed planning' )
SiemensPhase.create( code: '%PM300', label_p: 'Purchasing & manufacture', label_m: 'Dispatch approval' )
SiemensPhase.create( code: '%PM400', label_p: 'Dispatch',                 label_m: 'Material & resources at site' )
SiemensPhase.create( code: '%PM550', label_p: 'Construction/Installation',label_m: 'Construction/Installation completed' )
SiemensPhase.create( code: '%PM600', label_p: 'Commissioning',            label_m: 'Release for customer acceptance' )
SiemensPhase.create( code: '%PM650', label_p: 'Acceptance',               label_m: 'Customer acceptance' )
SiemensPhase.create( code: '%PM670', label_p: 'Project closure',          label_m: 'Project closure' )
SiemensPhase.create( code: '%PM700', label_p: 'Warranty',                 label_m: 'End of Warranty' )

# - - - - - - - - - - Initial phase codes from above

SiemensPhase.find_each do |sp|
  PhaseCode.create do |pc|
    pc.code: code
    pc.siemens_phase_id: id
    pc.label: label_p
  end
end