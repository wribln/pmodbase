params = { person: { informal_name: 'joe', formal_name: 'john doe', 
  contact_infos_attributes: {
    home: { info_type: 'Home'},
    proj: { info_type: 'Project'}
    }
  }}
puts ">>> here we go <<<"
puts params.to_yaml
puts "no of Persons: " + Person.count.to_s
puts "no of ContactInfos: " + ContactInfo.count.to_s
p = Person.create(params[:person])
puts p.contact_infos.length
puts p.contact_infos.first
puts p.contact_infos.second
puts "no of Persons: " + Person.count.to_s
puts "no of ContactInfos: " + ContactInfo.count.to_s
puts p.inspect, p.errors