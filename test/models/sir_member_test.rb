require 'test_helper'
class SirMemberTest < ActiveSupport::TestCase

  test 'fixture usefulness' do
    # s1, s2 are members of sir_log_two, s3 of sir_log_one
    s1 = sir_members( :one )
    s2 = sir_members( :two )
    s3 = sir_members( :three )
    assert_not_nil s1.account_id
    assert_not_nil s2.account_id
    assert_not_nil s3.account_id
    assert_equal s1.account_id, accounts( :one ).id
    assert_equal s2.account_id, accounts( :two ).id
    assert_equal s3.account_id, accounts( :three ).id
    assert_not_nil s1.sir_log_id
    assert_not_nil s2.sir_log_id
    assert_not_nil s3.sir_log_id
    assert_equal s1.sir_log_id, sir_logs( :sir_log_two ).id
    assert_equal s2.sir_log_id, sir_logs( :sir_log_two ).id
    assert_equal s3.sir_log_id, sir_logs( :sir_log_one ).id
    assert s1.valid?
    assert s2.valid?
    assert s3.valid?
  end

  test 'required attributes' do
    tm = sir_members( :one )
    tx = tm.dup

    # validation fails because account would be added twice

    assert_not tx.valid?
    assert_includes tx.errors, :account_id

    # try to add the owner as member

    ax = accounts( :wop ).id
    assert tx.sir_log.user_is_owner_or_deputy?( ax )
    tx.account_id = ax
    assert_not tx.valid?
    assert_includes tx.errors, :account_id

    # try to set account_id to nil

    tx.account_id = nil
    assert_not tx.valid?
    assert_includes tx.errors, :account_id
    tx.account_id = accounts( :three ).id
    assert tx.valid?

    # try to set sir_log_id to nil

    tx.sir_log_id = nil 
    assert_not tx.valid?
    assert_includes tx.errors, :sir_log_id
    tx.sir_log_id = tm.sir_log_id
    assert tx.valid?

    tx.to_access = nil
    assert tx.valid? # because nil == false

    tx.to_update = nil
    assert tx.valid?
  end

end
