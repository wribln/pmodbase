require 'test_helper'
class Permission4GroupTest < ActiveSupport::TestCase

  setup do
    @p0 = Permission4Group.new
  end

  test "verify default settings" do
    assert_equal @p0.to_index, 0, "to_index"
    assert_equal @p0.to_create, 0, "to_create"
    assert_equal @p0.to_read, 0, "to_read"
    assert_equal @p0.to_update, 0, "to_update"
    assert_equal @p0.to_delete, 0, "to_delete"
    assert_nil @p0.group_id, "group_id"
    assert_nil @p0.feature_id, "feature_id"
    assert_nil @p0.account_id, "account_id"
    assert_not @p0.valid?
  end

  test "given feature must exist" do
    p = permission4_groups( :permission4_group_0 )
    p.feature_id = nil
    assert_not p.valid?
    assert_includes p.errors, :feature_id

    p.feature_id = FEATURE_ID_MAX_PLUS_ONE
    assert_not p.valid?
    assert_includes p.errors, :feature_id
  end

  test "given account must exist" do
    p = permission4_groups( :permission4_group_0 )
    p.account_id = nil
    assert_not p.valid?
    assert_includes p.errors, :account_id

    p.account_id = 0
    assert_not p.valid?
    assert_includes p.errors, :account_id
  end

  test "given group must be 0 or must exist" do
    p = permission4_groups( :permission4_group_0 )
    p.group_id = nil
    assert_not p.valid?
    assert_includes p.errors, :group_id

    p.group_id = 0
    assert p.valid?

    p.group_id = -1
    assert_not p.valid?
    assert_includes p.errors, :group_id
  end

  test "check minimum_permissions?" do
    assert_equal @p0.errors[ :base ].length, 0
    @p0.minimum_permissions
    assert_equal @p0.errors[ :base ].length, 1
    @p0.errors.clear
    @p0.to_index = 1
    assert_equal @p0.errors[ :base ].length, 0
  end

  test "interdependencies: to_update requires to_read access permission" do
    @p0.group_id = 0
    @p0.feature_id = features( :feature_1 ).id
    @p0.account_id = accounts( :account_wop ).id
    @p0.to_update = 1
    @p0.minimum_permissions
    assert_equal @p0.errors[ :base ].length, 0
    assert_not @p0.valid?
    @p0.to_read = 1
    assert @p0.valid?
  end

  test "method group_code" do
    @p0.group_id = nil
    assert_nil @p0.group_code
    @p0.group_id = 0
    assert @p0.group_code, I18n.t( 'permissions.all_groups' )
    @p0.group_id = groups( :group_one ).id
    assert @p0.group_code, @p0.group.code_with_id
  end

end
