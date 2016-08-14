require 'test_helper'
class TiaMemberTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    # t1, t2 are members of tia_list_two, t3 of tia_list_one
    t1 = tia_members( :one )
    t2 = tia_members( :two )
    t3 = tia_members( :three )
    assert_not_nil t1.account_id
    assert_not_nil t2.account_id
    assert_not_nil t3.account_id
    assert_equal t1.account_id, accounts( :one ).id
    assert_equal t2.account_id, accounts( :two ).id
    assert_equal t3.account_id, accounts( :three ).id
    assert_not_nil t1.tia_list_id
    assert_not_nil t2.tia_list_id
    assert_not_nil t3.tia_list_id
    assert_equal t1.tia_list_id, tia_lists( :tia_list_two ).id
    assert_equal t2.tia_list_id, tia_lists( :tia_list_two ).id
    assert_equal t3.tia_list_id, tia_lists( :tia_list_one ).id
    assert t1.valid?
    assert t2.valid?
    assert t3.valid?
  end

  test "required attributes" do
    tm = tia_members( :one )
    tx = tm.dup

    # validation fails because account would be added twice

    assert_not tx.valid?
    assert_includes tx.errors, :account_id

    # try to add the owner as member

    ax = accounts( :wop ).id
    assert tx.tia_list.user_is_owner_or_deputy?( ax )
    tx.account_id = ax
    assert_not tx.valid?
    assert_includes tx.errors, :account_id

    # try to set account_id to nil

    tx.account_id = nil
    assert_not tx.valid?
    assert_includes tx.errors, :account_id
    tx.account_id = accounts( :three ).id
    assert tx.valid?

    # try to set tia_list_id to nil

    tx.tia_list_id = nil 
    assert_not tx.valid?
    assert_includes tx.errors, :tia_list_id
    tx.tia_list_id = tm.tia_list_id
    assert tx.valid?

    tx.to_access = nil
    assert tx.valid? # because nil == false

    tx.to_update = nil
    assert tx.valid?
  end

end
