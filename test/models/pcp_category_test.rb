require 'test_helper'
class PcpCategoryTest < ActiveSupport::TestCase

  test 'fixture' do
    pc = pcp_categories( :one )
    assert pc.valid?, pc.errors.messages
    refute_nil pc.c_group_id
    refute_nil pc.p_group_id
    refute_nil pc.label
    refute_nil pc.c_owner_id
    refute_nil pc.p_owner_id
    refute_nil pc.description
  end

  test 'defaults' do
    pc = PcpCategory.new
    refute pc.valid?
    assert_includes pc.errors, :c_group_id
    assert_includes pc.errors, :p_group_id
    assert_includes pc.errors, :label
    assert_includes pc.errors, :c_owner_id
    assert_includes pc.errors, :p_owner_id

    pc.c_group_id = groups( :group_one ).id
    pc.p_group_id = groups( :group_two ).id
    pc.label = "test 1 2 3"
    pc.c_owner_id = accounts( :account_one ).id
    pc.p_owner_id = accounts( :account_two ).id
    assert pc.valid?
  end

  test 'group must exist' do
    ng = Group.new( code: 'NONO', label: 'nono', group_category_id: group_categories( :group_category_one ).id )
    assert ng.save, ng.errors.messages
    pc = pcp_categories( :one )
    assert pc.valid?
    pc.c_group_id = ng.id
    pc.p_group_id = ng.id
    assert ng.destroy
    refute pc.valid?
    assert_includes pc.errors, :c_group_id
    assert_includes pc.errors, :p_group_id
  end

  test 'account 1 must exist' do
    pc = pcp_categories( :one )
    assert pc.valid?
    assert accounts( :account_one ).destroy
    refute pc.valid?
    assert_includes pc.errors, :c_owner_id
  end

  test 'account 2 must exist' do
    pc = pcp_categories( :one )
    assert pc.valid?
    assert accounts( :account_two ).destroy
    refute pc.valid?
    assert_includes pc.errors, :p_owner_id
  end

  test 'c_owner must have access to respective group' do
    pc = pcp_categories( :one )
    pc.c_owner_id = accounts( :account_wop ).id
    refute pc.valid?
    assert_includes pc.errors, :c_owner_id
    pc.c_owner_id = nil
    refute pc.valid?
    assert_includes pc.errors, :c_owner_id
    pc.c_owner_id = accounts( :account_one ).id    
    assert pc.valid?
  end

  # same test but with specific group ( :account_one has access
  # to all groups, :account_two only for group_two )

  test 'c_owner must have access to specified group' do
    pc = pcp_categories( :one )
    assert_equal groups( :group_one ).id, pc.c_group_id
    pc.c_owner_id = accounts( :account_two ).id
    refute pc.valid?#
    pc.c_group_id = groups( :group_two ).id
    assert pc.valid?
  end

  test 'p_owner must have access to respective group' do
    pc = pcp_categories( :one )
    pc.p_owner_id = accounts( :account_wop ).id
    refute pc.valid?
    assert_includes pc.errors, :p_owner_id
    pc.p_owner_id = nil
    refute pc.valid?
    assert_includes pc.errors, :p_owner_id
    pc.p_owner_id = accounts( :account_one ).id    
    assert pc.valid?
  end

  # same test but with specific group ( :account_one has access
  # to all groups, :account_two only for group_two )

  test 'p_owner must have access to specified group' do
    pc = pcp_categories( :one )
    pc.p_group_id = groups( :group_one )
    pc.p_owner_id = accounts( :account_two ).id
    refute pc.valid?
    pc.p_group_id = groups( :group_two ).id
    assert pc.valid?
  end

  test 'c_deputy - if given - must exist' do
    pc = pcp_categories( :one )
    pc.c_deputy_id = nil
    assert pc.valid?
    pc.c_deputy_id = accounts( :account_wop ).id
    accounts( :account_wop ).destroy
    refute pc.valid?
    assert_includes pc.errors, :c_deputy_id
    pc.c_deputy_id = accounts( :account_one ).id
    assert pc.valid?
  end

  test 'p_deputy - if given - must exist' do
    pc = pcp_categories( :one )
    pc.p_deputy_id = nil
    assert pc.valid?
    pc.p_deputy_id = accounts( :account_wop ).id
    accounts( :account_wop ).destroy
    refute pc.valid?
    assert_includes pc.errors, :p_deputy_id
    pc.p_deputy_id = accounts( :account_one ).id
    assert pc.valid?
  end

  test 'permitted to create subject' do
    g1 = groups( :group_one ).id
    g2 = groups( :group_two ).id
    a0 = accounts( :account_wop )
    a1 = accounts( :account_one )
    a2 = accounts( :account_two )

    assert_equal 0, PcpCategory.permitted_to_create_subject( nil, a0 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( '',  a0 ).count
    assert_equal 0, PcpCategory.permitted_to_create_subject( [g1], a0 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g2], a0 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g1,g2], a0 ).count

    assert_equal 0, PcpCategory.permitted_to_create_subject( nil, a1 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( '',  a1 ).count
    assert_equal 0, PcpCategory.permitted_to_create_subject( [g1], a1 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g2], a1 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g1,g2], a1 ).count

    assert_equal 0, PcpCategory.permitted_to_create_subject( nil, a2 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( '',  a2 ).count
    assert_equal 0, PcpCategory.permitted_to_create_subject( [g1], a2 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g2], a2 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g1,g2], a2 ).count

    pc = pcp_categories( :one )
    pc.p_deputy_id = accounts( :account_two ).id
    assert pc.save

    assert_equal 1, PcpCategory.permitted_to_create_subject( nil, a2 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( '',  a2 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g1], a2 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g2], a2 ).count
    assert_equal 1, PcpCategory.permitted_to_create_subject( [g1,g2], a2 ).count
  end
end
