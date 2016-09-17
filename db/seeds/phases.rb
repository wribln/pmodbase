# - - - - - - - - - - Siemens phase standard

puts
puts '>>> Loading Siemens Phases'

SiemensPhase.new do |sp|
  sp.code = '%PM010'
  sp.label_p = 'Lead Management'
  sp.label_m = 'Go / No-Go decision'
end.save

SiemensPhase.new do |sp|
  sp.code = '%PM020'
  sp.label_p = 'Opportunity Development'
  sp.label_m = 'Bid decision'
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM040"
  sp.label_p = "Bid Preparation"
  sp.label_m = "Bid approval"
end.save

SiemensPhase.new do |sp|
  sp.code = '%PM070'
  sp.label_p = 'Contract Negotiation'
  sp.label_m = 'Project won / lost'
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM080"
  sp.label_p = "Project Handover"
  sp.label_m = "Start of project"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM100"
  sp.label_p = "Project opening & clarification"
  sp.label_m = "Order receipt clarified"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM200"
  sp.label_p = "Detailed planning"
  sp.label_m = "Approval of detailed planning"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM300"
  sp.label_p = "Purchasing & manufacture"
  sp.label_m = "Dispatch approval"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM400"
  sp.label_p = "Dispatch"
  sp.label_m = "Material & resources at site"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM550"
  sp.label_p = "Construction/Installation"
  sp.label_m = "Construction/Installation completed"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM600"
  sp.label_p = "Commissioning"
  sp.label_m = "Release for customer acceptance"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM650"
  sp.label_p = "Acceptance"
  sp.label_m = "Customer acceptance"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM670"
  sp.label_p = "Project closure"
  sp.label_m = "Project closure"
end.save

SiemensPhase.new do |sp|
  sp.code = "%PM700"
  sp.label_p = "Warranty"
  sp.label_m = "End of Warranty"
end.save

# - - - - - - - - - - Initial phase codes from above

SiemensPhase.find_each do |sp|
  PhaseCode.create do |pc|
    pc.code = sp.code
    pc.siemens_phase_id = sp.id
    pc.label = sp.label_p
  end
end