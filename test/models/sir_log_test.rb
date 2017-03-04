require 'test_helper'
class SirLogTest < ActiveSupport::TestCase

  test 'fixture usefulness' do
    sl = sir_logs( :sir_log_one )
    assert sl.code.length < MAX_LENGTH_OF_CODE
    assert sl.label.length <= MAX_LENGTH_OF_DESCRIPTION
    assert_not_nil sl.owner_account_id
    assert_not_nil sl.deputy_account_id
    refute sl.archived

    sl = sir_logs( :sir_log_two )
    assert sl.code.length < MAX_LENGTH_OF_CODE
    assert sl.label.length <= MAX_LENGTH_OF_DESCRIPTION
    assert_not_nil sl.owner_account_id
    assert_nil sl.deputy_account_id
    refute sl.archived
  end

  test 'required attributes' do
    sl = SirLog.new
    refute sl.valid?
    assert_includes sl.errors, :code
    sl.code = 'ABC'

    refute sl.valid?
    assert_includes sl.errors, :label
    sl.label = 'ABC-Test'

    refute sl.valid?
    assert_includes sl.errors, :owner_account_id
    sl.owner_account = accounts( :one )

    assert sl.valid?, sl.errors.messages
  end

  test 'item code' do
    sl = sir_logs( :sir_log_one )
    assert_equal 'SL1-1', sl.item_code( 1 )
    assert_equal 'SL1-11', sl.item_code( 11 )
    assert_equal 'SL1-?', sl.item_code( nil )
    sl.code = nil 
    assert_equal '-1', sl.item_code( 1 )
    assert_equal '-11', sl.item_code( 11 )
    assert_equal '-?', sl.item_code( nil )
  end

  test 'code shall not have leading/trailing blanks' do
    sl = SirLog.new
    [ 'ABC', '  ABC', 'ABC  ', '  ABC  ' ].each do |c|
      sl.code = c
      assert_equal 'ABC', sl.code
    end
  end

  test 'label shall not have leading/trailing blanks' do
    sl = SirLog.new
    [ 'a label', '  a label', 'a label  ', '  a label  ', '  a  label  ' ].each do |c|
      sl.label = c
      assert_equal 'a label', sl.label
    end
  end

  test 'one owner should not use same code twice' do
    s1 = sir_logs( :sir_log_one )
    s2 = SirLog.new( code: s1.code, owner_account_id: s1.owner_account_id, label: s1.label )
    assert_not s2.valid?
    s2.code += '+'
    assert s2.valid?, s2.errors.messages
  end

  test 'given account must exist' do
    a1 = accounts( :two )
    id1 = a1.id
    assert_difference( 'Account.count', -1 ) do
      assert a1.delete
    end
    sl = sir_logs( :sir_log_one )

    id2 = sl.owner_account_id
    sl.owner_account_id = id1
    assert_not sl.valid?
    sl.owner_account_id = id2

    id2 = sl.deputy_account_id
    sl.deputy_account_id = id1
    assert_not sl.valid?
    sl.deputy_account_id = id2
  end 

  test 'owner or deputy?' do
    t = SirLog.new
    a = accounts( :wop ).id

    assert_not t.user_is_owner_or_deputy?( a )
    t.owner_account_id = a
    assert t.user_is_owner_or_deputy?( a )
    t.owner_account_id = nil
    assert_not t.user_is_owner_or_deputy?( a )
    t.deputy_account_id = a
    assert t.user_is_owner_or_deputy?( a )
  end

  test 'accounts_for_select 1' do
    sl = sir_logs( :sir_log_one )
    a = sl.accounts_for_select
    assert_equal a, a | [ accounts( :three ).id, accounts( :one ).id, accounts( :wop ).id ]
  end

  test 'accounts_for_select 2' do
    sl = sir_logs( :sir_log_two )
    a = sl.accounts_for_select
    assert_equal a, a | [ accounts( :one ).id, accounts( :two ).id, accounts( :wop ).id, ]
  end

  test 'scopes' do
    sl = SirLog.active
    assert_equal 2, sl.count

    sl[0].archived = true
    sl[0].save

    sl = SirLog.active
    assert_equal 1, sl.count
  end

end
