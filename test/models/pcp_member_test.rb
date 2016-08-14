require 'test_helper'
class PcpMemberTest < ActiveSupport::TestCase

  test 'fixture 1' do 
    pm = pcp_members( :one )
    assert_equal pm.pcp_subject_id, pcp_subjects( :two ).id
    assert_equal pm.account_id, accounts( :one ).id
    assert_equal pm.pcp_group, 0
    assert pm.to_access
    assert pm.to_update
    assert pm.valid?, pm.errors.inspect
  end

  test 'fixture 2' do 
    pm = pcp_members( :two )
    assert_equal pm.pcp_subject_id, pcp_subjects( :two ).id
    assert_equal pm.account_id, accounts( :wop ).id
    assert_equal pm.pcp_group, 1
    assert pm.to_access
    assert pm.to_update
    assert pm.valid?, pm.errors.inspect
  end

  test 'pcp subject must exist 1' do
    pm = pcp_members( :one )
    pm.pcp_subject_id = 0
    refute pm.valid?
    assert_includes pm.errors, :pcp_subject_id
  end

  test 'pcp subject must exist 2' do
    pm = pcp_members( :one )
    assert pcp_subjects( :two ).destroy
    refute pm.valid?
    assert_includes pm.errors, :pcp_subject_id
  end

  test 'account must exist 1' do
    pm = pcp_members( :two )
    pm.account_id = 0
    refute pm.valid?
    assert_includes pm.errors, :account_id
  end

  test 'account must exist 2' do
    pm = pcp_members( :two )
    assert accounts( :wop ).destroy
    refute pm.valid?
    assert_includes pm.errors, :account_id
  end

  test 'group labels' do
    assert_equal PcpMember.pcp_group_label( 0 ), pcp_members( :one ).pcp_group_label
    assert_equal PcpMember.pcp_group_label( 1 ), pcp_members( :two ).pcp_group_label
  end

  test 'scopes' do
    pm = pcp_subjects( :two ).pcp_members
    assert_equal 2, pm.length

    pm = pcp_subjects( :two ).pcp_members.presenting_group
    assert_equal 1, pm.length

    pm = pcp_subjects( :two ).pcp_members.commenting_group
    assert_equal 1, pm.length

    pm = pcp_subjects( :two ).pcp_members.presenting_member( accounts( :one ).id )
    assert_equal 1, pm.length

    pm = pcp_subjects( :two ).pcp_members.presenting_member( accounts( :two ).id )
    assert_equal 0, pm.length

    pm = pcp_subjects( :two ).pcp_members.presenting_member( accounts( :wop ).id )
    assert_equal 0, pm.length

    pm = pcp_subjects( :two ).pcp_members.commenting_member( accounts( :one ).id )
    assert_equal 0, pm.length

    pm = pcp_subjects( :two ).pcp_members.commenting_member( accounts( :two ).id )
    assert_equal 0, pm.length

    pm = pcp_subjects( :two ).pcp_members.commenting_member( accounts( :wop ).id )
    assert_equal 1, pm.length

  end

  test 'update requires access' do
    pm = pcp_members( :one )
    pm.to_access = true
    pm.to_update = false
    assert pm.valid?

    pm.to_access = false
    assert pm.valid?

    pm.to_update = true
    refute pm.valid?
    assert_includes pm.errors, :to_access

    pm.to_access = true
    assert pm.valid?
  end

end
