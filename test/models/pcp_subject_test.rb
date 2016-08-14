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
    assert_equal 0, ps.valid_subject?
    assert_equal 2, ps.pcp_steps.count
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
    assert_equal 0, ps.valid_subject?
    assert_equal 1, ps.pcp_steps.count
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
    assert_equal ps.p_owner_id, oc.p_owner_id
    assert_equal ps.c_deputy_id, oc.c_deputy_id
    assert_equal ps.p_deputy_id, oc.p_deputy_id
  end

  test 'check required attributes' do
    ps = PcpSubject.new
    ps.pcp_category_id = pcp_categories( :one ).id
    ps.c_owner_id = accounts( :one ).id
    ps.p_owner_id = accounts( :one ).id
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

  test 'permit to set p defaults from PCP Category' do
    ps = pcp_subjects( :two )
    assert_equal ps.p_group_id, groups( :group_one ).id
    assert_equal ps.p_owner_id, accounts( :one ).id
    ps.p_group_id = nil
    # should just set group and leave owner alone
    assert ps.valid?
    assert_equal ps.p_group_id, groups( :group_two ).id
    assert_equal ps.p_owner_id, accounts( :one ).id
    ps.p_group_id = nil
    ps.p_owner_id = nil
    assert ps.valid?
    # should set group and account
    assert_equal ps.p_group_id, groups( :group_two ).id
    assert_equal ps.p_owner_id, accounts( :two ).id
  end

  test 'permit to set c defaults from PCP Category' do
    ps = pcp_subjects( :two )
    assert_equal ps.c_group_id, groups( :group_two ).id
    assert_equal ps.c_owner_id, accounts( :two ).id
    ps.c_group_id = nil
    # should just set group and leave owner alone ...
    # but this fails as account_two does not have access
    # to group_one
    refute ps.valid?
    assert_includes ps.errors, :c_owner_id
    assert_equal ps.c_group_id, groups( :group_one ).id
    assert_equal ps.c_owner_id, accounts( :two ).id
    # try again
    ps.c_group_id = nil
    ps.c_owner_id = nil
    assert ps.valid?
    # should set group and account
    assert_equal ps.c_group_id, groups( :group_one ).id
    assert_equal ps.c_owner_id, accounts( :one ).id
  end

  test 'c_owner must have access to respective group' do
    ps = pcp_subjects( :one )
    ps.c_owner_id = accounts( :wop ).id
    refute ps.valid?
    assert_includes ps.errors, :c_owner_id
    ps.c_owner_id = nil
    refute ps.valid?
    assert_includes ps.errors, :c_owner_id
    ps.c_owner_id = accounts( :one ).id    
    assert ps.valid?
  end

  # same test but with specific group ( :one has access
  # to all groups, :two only for group_two )

  test 'c_owner must have access to specified group' do
    ps = pcp_subjects( :one )
    assert_equal groups( :group_one ).id, ps.c_group_id
    ps.c_owner_id = accounts( :two ).id
    refute ps.valid?#
    ps.c_group_id = groups( :group_two ).id
    assert ps.valid?
  end

  test 'p_owner must have access to respective group' do
    ps = pcp_subjects( :one )
    ps.p_owner_id = accounts( :wop ).id
    refute ps.valid?
    assert_includes ps.errors, :p_owner_id
    ps.p_owner_id = nil
    refute ps.valid?
    assert_includes ps.errors, :p_owner_id
    ps.p_owner_id = accounts( :one ).id    
    assert ps.valid?
  end

  # same test but with specific group ( :one has access
  # to all groups, :two only for group_two )

  test 'p_owner must have access to specified group' do
    ps = pcp_subjects( :one )
    assert_equal groups( :group_one ).id, ps.p_group_id
    ps.p_owner_id = accounts( :two ).id
    refute ps.valid?#
    ps.p_group_id = groups( :group_two ).id
    assert ps.valid?
  end

  test 'c_deputy - if given - must exist' do
    ps = pcp_subjects( :one )
    ps.c_deputy_id = nil
    assert ps.valid?
    ps.c_deputy_id = accounts( :wop ).id
    accounts( :wop ).destroy
    refute ps.valid?
    assert_includes ps.errors, :c_deputy_id
    ps.c_deputy_id = accounts( :one ).id
    assert ps.valid?
  end

  test 'p_deputy - if given - must exist' do
    ps = pcp_subjects( :one )
    ps.p_deputy_id = nil
    assert ps.valid?
    ps.p_deputy_id = accounts( :wop ).id
    accounts( :wop ).destroy
    refute ps.valid?
    assert_includes ps.errors, :p_deputy_id
    ps.p_deputy_id = accounts( :one ).id
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

  test 'current_steps' do
    ps = pcp_subjects( :one )
    assert 2, PcpStep.count
    assert 2, ps.pcp_steps.count
    s1 = pcp_steps( :one_one )
    s2 = pcp_steps( :one_two )
    assert_equal ps.current_steps[ 0 ].id, s2.id
    assert_equal ps.pcp_steps[ 0 ].id, s2.id
    assert_equal ps.pcp_steps[ 1 ].id, s1.id
    assert_equal ps.current_step.id, s2.id
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
    c1 = accounts( :one )
    c2 = accounts( :two )
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    assert ps.user_is_owner_or_deputy?( c1, 1 )
    refute ps.user_is_owner_or_deputy?( c2, 0 )
    refute ps.user_is_owner_or_deputy?( c2, 1 )
    ps.p_deputy = c2
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    assert ps.user_is_owner_or_deputy?( c1, 1 )
    assert ps.user_is_owner_or_deputy?( c2, 0 )
    refute ps.user_is_owner_or_deputy?( c2, 1 )
    ps.p_deputy = nil
    ps.c_deputy = c2
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    assert ps.user_is_owner_or_deputy?( c1, 1 )
    refute ps.user_is_owner_or_deputy?( c2, 0 )
    assert ps.user_is_owner_or_deputy?( c2, 1 )
    ps.c_owner = nil
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    refute ps.user_is_owner_or_deputy?( c1, 1 )
    refute ps.user_is_owner_or_deputy?( c2, 0 )
    assert ps.user_is_owner_or_deputy?( c2, 1 )
    ps.c_owner = c2
    ps.c_deputy = nil
    assert ps.user_is_owner_or_deputy?( c1, 0 )
    refute ps.user_is_owner_or_deputy?( c1, 1 )
    refute ps.user_is_owner_or_deputy?( c2, 0 )
    assert ps.user_is_owner_or_deputy?( c2, 1 )
  end

  test 'user access - user is creator' do
    ps = pcp_subjects( :one )
    assert ps.s_owner_id.nil?
    refute ps.user_is_creator?( nil )
    ps.s_owner = accounts( :one )
    refute ps.user_is_creator?( nil )
    refute ps.user_is_creator?( accounts( :two ))
    assert ps.user_is_creator?( accounts( :one ))
  end

  test 'acting and viewing group' do
    ps = pcp_subjects( :one )
    ps.pcp_members.destroy

    # we have the same account for both presenting and commenting group

    assert_equal ps.p_owner_id, ps.c_owner_id
    assert_equal 1, ps.current_steps[ 0 ].acting_group_index
    pvgi = ps.viewing_group_map( ps.p_owner )
    cvgi = ps.viewing_group_map( ps.c_owner )
    assert_equal 3, pvgi
    assert_equal 3, cvgi

    assert PcpSubject.same_group?( 0, pvgi )
    assert PcpSubject.same_group?( 0, cvgi )
    assert PcpSubject.same_group?( 1, pvgi )
    assert PcpSubject.same_group?( 1, cvgi )

    # now try different accounts

    ps.c_owner_id = accounts( :two ).id
    refute_equal ps.p_owner_id, ps.c_owner_id
    cvgi = ps.viewing_group_map( ps.c_owner )
    pvgi = ps.viewing_group_map( ps.p_owner )
    assert_equal 1, pvgi
    assert_equal 2, cvgi

    assert PcpSubject.same_group?( 0, pvgi )
    assert PcpSubject.same_group?( 1, cvgi )
    refute PcpSubject.same_group?( 1, pvgi )
    refute PcpSubject.same_group?( 0, cvgi )

    # test for account outside of both groups

    xvgi = ps.viewing_group_map( accounts( :wop ))
    assert_equal 0, xvgi
    refute PcpSubject.same_group?( 1, xvgi )
    refute PcpSubject.same_group?( 0, xvgi )

  end

  test 'special access test' do
    ps = PcpSubject.new
    assert_equal 0, ps.viewing_group_map( accounts( :one  ))
    assert_equal 0, ps.viewing_group_map( accounts( :two  ))
    assert_equal 0, ps.viewing_group_map( accounts( :three))
    assert_equal 0, ps.viewing_group_map( accounts( :wop  ))
    ps.s_owner_id = accounts( :wop ).id
    assert_equal 0, ps.viewing_group_map( accounts( :one  ))
    assert_equal 0, ps.viewing_group_map( accounts( :two  ))
    assert_equal 0, ps.viewing_group_map( accounts( :three))
    assert_equal 1, ps.viewing_group_map( accounts( :wop  ))
    ps.c_deputy_id = ps.s_owner_id
    assert_equal 0, ps.viewing_group_map( accounts( :one  ))
    assert_equal 0, ps.viewing_group_map( accounts( :two  ))
    assert_equal 0, ps.viewing_group_map( accounts( :three))
    assert_equal 3, ps.viewing_group_map( accounts( :wop  ))
  end

  test 'viewing group map' do
    ps = pcp_subjects( :two )
    assert_equal ps.pcp_members.where( pcp_group: 0 ).first.account, accounts( :one )
    assert_equal ps.pcp_members.where( pcp_group: 1 ).first.account, accounts( :wop )
    assert_equal ps.p_owner, accounts( :one )
    assert_equal ps.c_owner, accounts( :two ) 
    ps.s_owner = accounts( :three )
    assert_equal 1, ps.viewing_group_map( accounts( :one ))
    assert_equal 2, ps.viewing_group_map( accounts( :two ))
    assert_equal 1, ps.viewing_group_map( accounts( :three ))
    assert_equal 2, ps.viewing_group_map( accounts( :wop ))
    ps.p_deputy = accounts( :three )
    assert_equal 1, ps.viewing_group_map( accounts( :three ))
    ps.c_deputy = accounts( :three )
    assert_equal 3, ps.viewing_group_map( accounts( :three ))
    ps.p_deputy = nil
    assert_equal 3, ps.viewing_group_map( accounts( :three ))
    ps.s_owner = nil
    assert_equal 2, ps.viewing_group_map( accounts( :three ))
    ps.c_deputy = nil
    assert_equal 0, ps.viewing_group_map( accounts( :three ))

    assert_difference( 'PcpMember.count', -2 )do
      ps.pcp_members.destroy_all
    end
    assert_equal 1, ps.viewing_group_map( accounts( :one ))
    assert_equal 2, ps.viewing_group_map( accounts( :two ))
    assert_equal 0, ps.viewing_group_map( accounts( :three ))
    assert_equal 0, ps.viewing_group_map( accounts( :wop ))
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

    as = PcpSubject.all_permitted( accounts( :one ).id )
    assert_equal 2, as.length

    as = PcpSubject.all_permitted( accounts( :two ).id )
    assert_equal 1, as.length
    assert_equal as[ 0 ].id, pcp_subjects( :two ).id

    as = PcpSubject.all_permitted( accounts( :wop ).id )
    assert_equal 1, as.length
    assert_equal as[ 0 ].id, pcp_subjects( :two ).id

  end

end
