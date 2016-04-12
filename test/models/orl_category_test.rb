require 'test_helper'
class OrlCategoryTest < ActiveSupport::TestCase

  test 'fixture' do
    ot = orl_categories( :one )
    assert ot.valid?, ot.errors.messages
    refute_nil ot.o_group_id
    refute_nil ot.r_group_id
    refute_nil ot.label
    refute_nil ot.o_owner_id
    refute_nil ot.r_owner_id
  end

  test 'defaults' do
    ot = OrlCategory.new
    refute ot.valid?
    assert_includes ot.errors, :o_group_id
    assert_includes ot.errors, :r_group_id
    assert_includes ot.errors, :label
    assert_includes ot.errors, :o_owner_id
    assert_includes ot.errors, :r_owner_id

    ot.o_group_id = groups( :group_one ).id
    ot.r_group_id = groups( :group_two ).id
    ot.label = "test 1 2 3"
    ot.o_owner_id = accounts( :account_one ).id
    ot.r_owner_id = accounts( :account_two ).id
    assert ot.valid?
  end

  test 'group must exist' do
    ng = Group.new( code: 'NONO', label: 'nono', group_category_id: group_categories( :group_category_one ).id )
    assert ng.save, ng.errors.messages
    ot = orl_categories( :one )
    assert ot.valid?
    ot.o_group_id = ng.id
    ot.r_group_id = ng.id
    assert ng.destroy
    refute ot.valid?
    assert_includes ot.errors, :o_group_id
    assert_includes ot.errors, :r_group_id
  end

  test 'account 1 must exist' do
    ot = orl_categories( :one )
    assert ot.valid?
    assert accounts( :account_one ).destroy
    refute ot.valid?
    assert_includes ot.errors, :o_owner_id
  end

  test 'account 2 must exist' do
    ot = orl_categories( :one )
    assert ot.valid?
    assert accounts( :account_two ).destroy
    refute ot.valid?
    assert_includes ot.errors, :r_owner_id
  end

end
