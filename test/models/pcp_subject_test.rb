require 'test_helper'
class PcpSubjectTest < ActiveSupport::TestCase

  test 'check fixture' do
    ps = pcp_subjects( :one )
    refute_empty ps.desc
    refute_empty ps.note
    refute_empty ps.project_doc_id
    refute_empty ps.report_doc_id
    refute_nil ps.c_group_id
    refute_nil ps.p_group_id
    refute_nil ps.pcp_category_id
    refute_nil ps.c_owner_id
    refute_nil ps.p_owner_id
    assert_nil ps.c_deputy_id
    assert_nil ps.p_deputy_id
    assert ps.valid?, ps.errors.messages
  end

  test 'create new subject with defaults' do
    ps = PcpSubject.new
    refute ps.valid?
    assert_includes ps.errors, :pcp_category_id
    refute_includes ps.errors, :c_owner_id
    refute_includes ps.errors, :p_owner_id
    refute_includes ps.errors, :c_group_id
    refute_includes ps.errors, :p_group_id
    refute_includes ps.errors, :c_deputy_id
    refute_includes ps.errors, :p_deputy_id
    refute_includes ps.errors, :desc
    refute_includes ps.errors, :note
    refute_includes ps.errors, :project_doc_id
    refute_includes ps.errors, :report_doc_id
  end

  test 'new object inherits defaults from given pcp_category' do
    ps = PcpSubject.new
    oc = pcp_categories( :one )
    ps.pcp_category = oc
    assert ps.valid?
    assert_equal ps.c_group_id, oc.c_group_id
    assert_equal ps.p_group_id, oc.p_group_id
    assert_equal ps.c_owner_id, oc.c_owner_id
    assert_equal ps.p_owner_id, oc.p_owner_id
    assert_equal ps.c_deputy_id, oc.c_deputy_id
    assert_equal ps.p_deputy_id, oc.p_deputy_id
  end

  test 'check required attributes' do
    ps = PcpSubject.new
    ps.pcp_category_id = pcp_categories( :one ).id
    ps.c_owner_id = accounts( :account_one ).id
    ps.p_owner_id = accounts( :account_one ).id
    ps.c_group_id = groups( :group_one ).id
    ps.p_group_id = groups( :group_one ).id
    assert ps.valid?, ps.errors.messages
  end

  test 'pcp_category must be valid' do
    ps = pcp_subjects( :one )
    ps.pcp_category_id = nil 
    refute ps.valid?
    assert_includes ps.errors, :pcp_category_id
    ps.pcp_category_id = 0
    refute ps.valid?
    assert_includes ps.errors, :pcp_category_id
    ps.pcp_category_id = pcp_categories( :one ).id 
    assert ps.valid?
    oc = pcp_categories( :one ).dup 
    oc.save
    ps.pcp_category_id = oc.id
    assert ps.valid?
    oc.destroy
    refute ps.valid?, ps.errors.messages
  end

  test 'o_owner must have access to respective group' do
    ps = pcp_subjects( :one )
    ps.c_owner_id = accounts( :account_wop ).id
    refute ps.valid?
    assert_includes ps.errors, :c_owner_id
    ps.c_owner_id = nil
    refute ps.valid?
    assert_includes ps.errors, :c_owner_id
    ps.c_owner_id = accounts( :account_one ).id    
    assert ps.valid?
  end

  # same test but with specific group ( :account_one has access
  # to all groups, :account_two only for group_two )

  test 'c_owner must have access to specified group' do
    ps = pcp_subjects( :one )
    assert_equal groups( :group_one ).id, ps.c_group_id
    ps.c_owner_id = accounts( :account_two ).id
    refute ps.valid?#
    ps.c_group_id = groups( :group_two ).id
    assert ps.valid?
  end

  test 'p_owner must have access to respective group' do
    ps = pcp_subjects( :one )
    ps.p_owner_id = accounts( :account_wop ).id
    refute ps.valid?
    assert_includes ps.errors, :p_owner_id
    ps.p_owner_id = nil
    refute ps.valid?
    assert_includes ps.errors, :p_owner_id
    ps.p_owner_id = accounts( :account_one ).id    
    assert ps.valid?
  end

  # same test but with specific group ( :account_one has access
  # to all groups, :account_two only for group_two )

  test 'p_owner must have access to specified group' do
    ps = pcp_subjects( :one )
    assert_equal groups( :group_one ).id, ps.p_group_id
    ps.p_owner_id = accounts( :account_two ).id
    refute ps.valid?#
    ps.p_group_id = groups( :group_two ).id
    assert ps.valid?
  end

  test 'c_deputy - if given - must have access to respective group' do
    ps = pcp_subjects( :one )
    ps.c_deputy_id = nil
    assert ps.valid?
    ps.c_deputy_id = accounts( :account_wop ).id
    refute ps.valid?
    assert_includes ps.errors, :c_deputy_id
    ps.c_deputy_id = accounts( :account_one ).id
    assert ps.valid?
  end

  test 'p_deputy - if given - must have access to respective group' do
    ps = pcp_subjects( :one )
    ps.p_deputy_id = nil
    assert ps.valid?
    ps.p_deputy_id = accounts( :account_wop ).id
    refute ps.valid?
    assert_includes ps.errors, :p_deputy_id
    ps.p_deputy_id = accounts( :account_one ).id
    assert ps.valid?
  end

end
