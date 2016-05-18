require 'test_helper'
class PcpSubjectTest < ActiveSupport::TestCase

  test 'check fixture 1' do
    ps = pcp_subjects( :one )
    refute_empty ps.title
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
    assert ps.pcp_steps.count > 0, 'A PCP Subject should have at least one PCP Step'
  end

  test 'check fixture 2' do
    ps = pcp_subjects( :two )
    refute_empty ps.title
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
    assert ps.pcp_steps.count > 0, 'A PCP Subject should have at least one PCP Step'
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
    refute_includes ps.errors, :title
    refute_includes ps.errors, :note
    refute_includes ps.errors, :project_doc_id
    refute_includes ps.errors, :report_doc_id
  end

  test 'new object inherits defaults from given pcp_category' do
    # except p_owner_id which will become the current user's id
    ps = PcpSubject.new
    oc = pcp_categories( :one )
    ps.pcp_category = oc
    assert ps.valid?
    assert_equal ps.c_group_id, oc.c_group_id
    assert_equal ps.p_group_id, oc.p_group_id
    assert_equal ps.c_owner_id, oc.c_owner_id
    assert_nil ps.p_owner_id
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

  test 'nice title' do
    ps = PcpSubject.new
    ps.id = 1
    assert_equal '[1]', ps.subject_title
    ps.project_doc_id = 'A-B-C-D'
    assert_equal 'A-B-C-D', ps.subject_title
    ps.title = 'foobar'
    assert_equal 'foobar', ps.subject_title
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

  # archived must be clear unless status of subject is closed

  test 'archive flag' do
    ps = pcp_subjects( :one )
    refute ps.archived
    refute ps.current_steps[ 0 ].status_closed?
    assert ps.valid?
    ps.archived = true
    refute ps.valid?
    assert_includes ps.errors, :archived

    pt = ps.current_steps[ 0 ]
    pt.subject_status = 2 # close
    assert pt.save, pt.errors.messages
    assert ps.valid?, ps.errors.messages
    ps.archived = true
    assert ps.valid?, pt.errors.messages
  end

  # check current step

  test 'current_step' do
    ps = pcp_subjects( :one )
    assert 2, PcpStep.count
    assert 2, ps.pcp_steps.count
    s1 = pcp_steps( :one )
    s2 = pcp_steps( :two )
    assert_equal ps.current_steps[ 0 ].id, s2.id
    assert_equal ps.pcp_steps[ 0 ].id, s2.id
    assert_equal ps.pcp_steps[ 1 ].id, s1.id
  end

  test 'get_acting_group' do
    ps = pcp_subjects( :one )
    gp = ps.p_group_id
    pc = ps.c_group_id
    assert ps.p_group_id, ps.get_acting_group( 0 ).id
    assert ps.c_group_id, ps.get_acting_group( 1 ).id
  end

  test 'user access - p_group/owner == c_group/owner' do
    ps = pcp_subjects( :one )
    c1 = accounts( :account_one ).id
    c2 = accounts( :account_two ).id
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    assert ps.user_is_owner_or_deputy?( c1, 1 )
    refute ps.user_is_owner_or_deputy?( c2, 0 )
    refute ps.user_is_owner_or_deputy?( c2, 1 )
    ps.p_deputy_id = c2
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    assert ps.user_is_owner_or_deputy?( c1, 1 )
    assert ps.user_is_owner_or_deputy?( c2, 0 )
    refute ps.user_is_owner_or_deputy?( c2, 1 )
    ps.p_deputy_id = nil
    ps.c_deputy_id = c2
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    assert ps.user_is_owner_or_deputy?( c1, 1 )
    refute ps.user_is_owner_or_deputy?( c2, 0 )
    assert ps.user_is_owner_or_deputy?( c2, 1 )
    ps.c_owner_id = nil
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    refute ps.user_is_owner_or_deputy?( c1, 1 )
    refute ps.user_is_owner_or_deputy?( c2, 0 )
    assert ps.user_is_owner_or_deputy?( c2, 1 )
    ps.c_owner_id = c2
    ps.c_deputy_id = nil
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    refute ps.user_is_owner_or_deputy?( c1, 1 )
    refute ps.user_is_owner_or_deputy?( c2, 0 )
    assert ps.user_is_owner_or_deputy?( c2, 1 )
  end

  test 'acting and viewing group' do
    ps = pcp_subjects( :one )
    ps.pcp_members.destroy

    # we have the same account for both presenting and commenting group

    assert_equal ps.p_owner_id, ps.c_owner_id
    assert_equal 1, ps.current_steps[ 0 ].acting_group_index
    pvgi = ps.viewing_group_map( ps.p_owner_id )
    cvgi = ps.viewing_group_map( ps.c_owner_id )
    assert_equal 3, pvgi
    assert_equal 3, cvgi

    assert PcpSubject.same_group?( 0, pvgi )
    assert PcpSubject.same_group?( 0, cvgi )
    assert PcpSubject.same_group?( 1, pvgi )
    assert PcpSubject.same_group?( 1, cvgi )

    # now try different accounts

    ps.c_owner_id = accounts( :account_two ).id
    refute_equal ps.p_owner_id, ps.c_owner_id
    cvgi = ps.viewing_group_map( ps.c_owner_id )
    pvgi = ps.viewing_group_map( ps.p_owner_id )
    assert_equal 1, pvgi
    assert_equal 2, cvgi

    assert PcpSubject.same_group?( 0, pvgi )
    assert PcpSubject.same_group?( 1, cvgi )
    refute PcpSubject.same_group?( 1, pvgi )
    refute PcpSubject.same_group?( 0, cvgi )

    # test for account outside of both groups

    xvgi = ps.viewing_group_map( accounts( :account_wop ).id )
    assert_equal 0, xvgi
    refute PcpSubject.same_group?( 1, xvgi )
    refute PcpSubject.same_group?( 0, xvgi )

  end

  test 'all scopes' do

    # mainly to ensure that the syntax there is correct ...

    as = PcpSubject.all_active
    assert_equal 2, as.length

    as = PcpSubject.ff_id( pcp_subjects( :one ).id )
    assert_equal 1, as.length

    as = PcpSubject.ff_id( pcp_subjects( :two ).id )
    assert_equal 1, as.length

    as = PcpSubject.ff_id( 0 )
    assert_equal 0, as.length

    as = PcpSubject.ff_titl( 'TEST')
    assert_equal 2, as.length

    as = PcpSubject.ff_titl( 'foobar')
    assert_equal 0, as.length

    as = PcpSubject.ff_igrp( groups( :group_one ).id )
    assert_equal 2, as.length

    as = PcpSubject.ff_igrp( groups( :group_two ).id )
    assert_equal 1, as.length

    as = PcpSubject.ff_note( '#tags' )
    assert_equal 2, as.length

    as = PcpSubject.ff_note( 'notes' )
    assert_equal 2, as.length

    as = PcpSubject.ff_note( 'foobar' )
    assert_equal 0, as.length
  end

end
