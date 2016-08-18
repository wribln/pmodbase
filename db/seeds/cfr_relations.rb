# - - - - - - - - - - CfrRelations

def create_pair( rg, l1, l2 )
  t1 = CfrRelationship.new
  t1.rs_group = rg
  t1.label = l1
  t1.leading = true
  t2 = t1.build_reverse_rs( rs_group: rg, leading: false )
  t2.label = l2
  t1.save
  t1.update_attribute( :reverse_rs_id, t2.id )
  print '.'
end

create_pair( 0, 'is predecessor of', 'is successor of' )
create_pair( 0, 'is request for', 'is reply to' )
create_pair( 0, 'is question for', 'is answer to' )
create_pair( 0, 'replaces', 'is replaced by' )

create_pair( 1, 'is parent of', 'is child of' )
create_pair( 1, 'is master of', 'is slave of' )
create_pair( 1, 'is main document of',  'is attachment of (main)'  )
create_pair( 1, 'is cover document of', 'is attachment of (cover)' )
create_pair( 1, 'is basis of', 'is excerpt of' )
create_pair( 1, 'contains', 'is contained in' )
create_pair( 1, 'is folder of', 'is file in folder' )
create_pair( 1, 'is volume of', 'is part of volume' )
create_pair( 1, 'references', 'is referenced by' )

create_pair( 2, 'is released by', 'is release document for' )
create_pair( 2, 'is differently formatted than', 'has different format than' )

puts