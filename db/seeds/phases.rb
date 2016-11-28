# - - - - - - - - - - Siemens phase standard

puts
puts '>>> Loading Siemens Phases - as per PM@Siemens Guide Version 6.0.2, released 04.10.2016'

SiemensPhase.create( code: '%PM010', label_p: 'Lead Management',          label_m: 'Go / No-Go Decision' )
SiemensPhase.create( code: '%PM020', label_p: 'Opportunity Development',  label_m: 'Bid Decision' )
SiemensPhase.create( code: '%PM040', label_p: 'Bid Preparation',          label_m: 'Bid Approval' )
SiemensPhase.create( code: '%PM070', label_p: 'Contract Negotiation',     label_m: 'Project Won/Lost' )
SiemensPhase.create( code: '%PM080', label_p: 'Project Handover',         label_m: 'End of Handover' )
SiemensPhase.create( code: '%PM100', label_p: 'Project Opening & Clarification', label_m: 'Project Initiated' )
SiemensPhase.create( code: '%PM200', label_p: 'Detailed Planning',        label_m: 'Design Freeze' )
SiemensPhase.create( code: '%PM300', label_p: 'Purchasing & Manufacture', label_m: 'Ready to Ship' )
SiemensPhase.create( code: '%PM400', label_p: 'Dispatch',                 label_m: 'Deliverables & Resources at Site' )
SiemensPhase.create( code: '%PM550', label_p: 'Construction/Installation',label_m: 'Construction/Installation Completed' )
SiemensPhase.create( code: '%PM600', label_p: 'Commissioning',            label_m: 'Release for Customer Acceptance' )
SiemensPhase.create( code: '%PM650', label_p: 'Acceptance',               label_m: 'Preliminary Acceptance' )
SiemensPhase.create( code: '%PM670', label_p: 'Warranty',                 label_m: 'Final Acceptance' )
SiemensPhase.create( code: '%PM700', label_p: 'Project Closure',          label_m: 'End of Obligations' )

# - - - - - - - - - - Initial phase codes from above

SiemensPhase.find_each {|sp| PhaseCode.create( code: sp.code, siemens_phase_id: sp.id, label: sp.label_p )}
