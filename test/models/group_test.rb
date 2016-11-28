require 'test_helper'
class GroupTest < ActiveSupport::TestCase

  test 'default values of new record' do
    g = Group.new
    assert_equal g.code, ''
    assert_equal g.label, ''
    assert_equal g.seqno, 0
    assert_nil g.notes
    assert_nil g.group_category_id
  end

  test 'required parameters: code only' do
    g = Group.new
    assert_not g.valid?
    g.code = groups( :group_one ).code
    assert_not g.valid?
    g.code = ''
    assert_not g.valid?
  end

  test 'required parameters: label only' do
    g = Group.new
    g.label = groups( :group_one ).label
    assert_not g.valid?
    g.label = ''
    assert_not g.valid?
  end

  test 'required parameters: category only' do
    g = Group.new
    g.group_category_id = groups( :group_one ).group_category_id
    assert_not g.valid?
    g.group_category_id = nil
    assert_not g.valid?
  end

  test 'required parameters: notes only' do
    g = Group.new
    g.notes = 'Test Note'
    assert_not g.valid?
    g.notes = ''
    assert_not g.valid?
  end

  test 'required parameters: seqno only' do
    g = Group.new
    g.seqno = 1
    assert_not g.valid?
    g.seqno = nil
    assert_not g.valid?
  end

  test 'required parameters: all required' do
    g = Group.new
    t = groups( :group_one )
    g.code = t.code << 'a'
    assert_not g.valid?
    g.label = t.label
    assert_not g.valid?
    g.group_category_id = t.group_category_id
    assert g.valid?
  end
  
  test 'method label_with_id' do
    g = groups( :group_one )
    assert_equal text_with_id( g.label, g.id ), g.label_with_id
  end

  test 'method code_with_id' do
    g = groups( :group_one )
    assert_equal text_with_id( g.code, g.id ), g.code_with_id
  end

  test 'must not deactivate group while user is still has permissions for it' do
    g = groups( :group_one )
    assert g.active 
    g.active = false
    assert g.valid?, g.errors.messages
    p = permission4_groups( :permission4_group_f01 )
    p.group_id = g.id
    assert p.save, p.errors.messages
    refute g.valid?, g.errors.messages
    assert_includes g.errors, :base
    p.group_id = 0
    assert p.save, p.errors.messages
    assert g.valid?, p.errors.messages    
  end

  test 'master group must exist' do
    g1 = groups( :group_one )
    g2 = groups( :group_two )
    assert_equal g2.sub_group_of_id, g1.id
    g2.sub_group_of_id = 0
    refute g2.valid?
    assert_includes g2.errors, :sub_group_of_id
  end

  test 'cannot assign myself as master' do
    g = groups( :group_one )
    g.sub_group_of_id = g.id
    refute g.valid?, g.errors.messages
    assert_includes g.errors, :sub_group_of_id
  end

  test 'must not delete master group' do
    g = groups( :group_one )
    refute g.destroy
  end

  test 'get sub_groups' do
    g = Group.descendant_groups
    g1 = groups( :group_one ).id
    g2 = groups( :group_two ).id
    assert_equal [ g1, g2 ], g[ g1 ]
    assert_equal [ g2 ], g[ g2 ]
  end

  test 'test sub_groups' do
    g1 = groups( :group_one )
    g2 = groups( :group_two )
    g3 = Group.create(
      group_category: group_categories( :group_category_one ),
      code: 'XXX',
      label: 'Group 3',
      sub_group_of: g2 )
    g = Group.descendant_groups
    assert_equal 3, g[ g1.id ].length
    assert_includes g[ g1.id ], g1.id
    assert_includes g[ g1.id ], g2.id
    assert_includes g[ g1.id ], g3.id
    assert_equal 2, g[ g2.id ].length
    assert_includes g[ g2.id ], g2.id
    assert_includes g[ g2.id ], g3.id
    assert_equal 1, g[ g3.id ].length
    assert_includes g[ g3.id ], g3.id

    g3.update_attribute( :sub_group_of_id, g1.id )
    g = Group.descendant_groups
    assert_equal 3, g[ g1.id ].length
    assert_includes g[ g1.id ], g1.id
    assert_includes g[ g1.id ], g2.id
    assert_includes g[ g1.id ], g3.id
    assert_equal 1, g[ g2.id ].length
    assert_includes g[ g2.id ], g2.id
    assert_equal 1, g[ g3.id ].length
    assert_includes g[ g3.id ], g3.id

    g1.update_attribute( :sub_group_of_id, g3.id )
    g = Group.descendant_groups
    assert g.empty?
  end

end
