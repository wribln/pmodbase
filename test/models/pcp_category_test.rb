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

end
