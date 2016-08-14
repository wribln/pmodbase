require 'test_helper'
class TiaListTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    tia = tia_lists( :tia_list_one )
    assert tia.code.length < MAX_LENGTH_OF_CODE
    assert tia.label.length <= MAX_LENGTH_OF_DESCRIPTION
    assert_not_nil tia.owner_account_id
    assert_not_nil tia.deputy_account_id
  end

  test "item code" do
    tia = tia_lists( :tia_list_one )
    assert_equal 'TIA-1', tia.item_code( 1 )
    assert_equal 'TIA-11', tia.item_code( 11 )
    tia.code = nil 
    assert_equal '-1-', tia.item_code( 1 )
    assert_equal '-11-', tia.item_code( 11 )
  end

  test "code shall not have leading/trailing blanks" do
    tia = TiaList.new
    [ 'ABC', '  ABC', 'ABC  ', '  ABC  ' ].each do |c|
      tia.code = c
      assert_equal 'ABC', tia.code
    end
  end

  test "label shall not have leading/trailing blanks" do
    tia = TiaList.new
    [ 'a label', '  a label', 'a label  ', '  a label  ', '  a  label  ' ].each do |c|
      tia.label = c
      assert_equal 'a label', tia.label
    end
  end

  test "one owner should not use same code twice" do
    t1 = tia_lists( :tia_list_one )
    t2 = TiaList.new
    t2.code = t1.code
    t2.owner_account_id = t1.owner_account_id
    assert_not t2.valid?
    t2.code += '+'
    assert t2.valid?
  end

  test "given account must exist" do
    a1 = accounts( :two )
    id1 = a1.id
    assert_difference( 'Account.count', -1 ) do
      assert a1.delete
    end
    tia = tia_lists( :tia_list_one )

    id2 = tia.owner_account_id
    tia.owner_account_id = id1
    assert_not tia.valid?
    tia.owner_account_id = id2

    id2 = tia.deputy_account_id
    tia.deputy_account_id = id1
    assert_not tia.valid?
    tia.deputy_account_id = id2
  end 

  test "owner or deputy?" do
    t = TiaList.new
    a = accounts( :wop ).id

    assert_not t.user_is_owner_or_deputy?( a )
    t.owner_account_id = a
    assert t.user_is_owner_or_deputy?( a )
    t.owner_account_id = nil
    assert_not t.user_is_owner_or_deputy?( a )
    t.deputy_account_id = a
    assert t.user_is_owner_or_deputy?( a )
  end

  test "accounts_for_select 1" do
    t = tia_lists( :tia_list_one )
    a = t.accounts_for_select
    assert_equal a, a | [ accounts( :three ).id, accounts( :one ).id, accounts( :wop ).id ]
  end

  test "accounts_for_select 2" do
    t = tia_lists( :tia_list_two )
    a = t.accounts_for_select
    assert_equal a, a | [ accounts( :one ).id, accounts( :two ).id, accounts( :wop ).id, ]
  end

end
