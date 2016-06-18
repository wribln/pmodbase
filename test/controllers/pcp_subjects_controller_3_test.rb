require 'test_helper'
class PcpSubjectsController3Test < ActionController::TestCase
  tests PcpSubjectsController

  # this test suite is about the creator of the PCP Subject:
  # initially, she must be able to create PCP Subjects, i.e.
  # she must have permission for all or a specific group for
  # the PcpSubjectController (FEATURE_ID_MY_PCP_SUBJECTS).

  # during creation of a PCP Subject, she can still make changes
  # to the PCP Category and selected PCP Subject attributes.

  # later, the creator of the PCP Subject has the same permissions
  # as PCP Members with update access.

  setup do 
    @pcp_category = pcp_categories( :one )
    @account = accounts( :account_wop )
    session[ :current_user_id ] = @account.id
  end

  # give user without permissions access to a group

  test 'user has access for different group' do
    g = Group.new(
      code: 'FOO',
      label: 'bar',
      group_category_id: group_categories( :group_category_one ).id )
    assert g.save, g.errors.inspect
    p = Permission4Group.new( 
      account_id: @account.id,
      feature_id: FEATURE_ID_MY_PCP_SUBJECTS,
      group_id: g.id,
      to_index: 1, to_create: 1, to_read: 1, to_update: 1 )
    assert p.save, p.errors.inspect
    #
    assert_no_difference( 'PcpSubject.count' ) do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_category.id,
        title: 'more foobar' }
    end
    assert_response :forbidden
  end

  test 'user has access to commenting group' do
    p = Permission4Group.new( 
      account_id: @account.id,
      feature_id: FEATURE_ID_MY_PCP_SUBJECTS,
      group_id: @pcp_category.c_group_id,
      to_index: 1, to_create: 1, to_read: 1, to_update: 1 )
    assert p.save, p.errors.inspect
    #
    assert_no_difference( 'PcpSubject.count' ) do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_category.id,
        title: 'more foobar' }
    end
    assert_response :forbidden
  end

  test 'finally, user has access to presenting group' do
    p = Permission4Group.new( 
      account_id: @account.id,
      feature_id: FEATURE_ID_MY_PCP_SUBJECTS,
      group_id: @pcp_category.p_group_id,
      to_index: 1, to_create: 1, to_read: 1, to_update: 1 )
    assert p.save, p.errors.inspect
    #
    p = PcpSubject.new( pcp_category_id: @pcp_category.id )
    assert p.permitted_to_create?( @account )
    assert_difference( 'PcpSubject.count', 1 ) do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_category.id,
        title: 'very foobar' }
    end
    @pcp_subject = assigns( :pcp_subject )
    assert_redirected_to pcp_subject_path( @pcp_subject )
    assert @pcp_subject.user_is_creator?( @account )

    # user is creator of this subject, she is permitted to make
    # changes to the basic attributes

    refute_equal @account.id, @pcp_subject.p_owner_id
    refute_equal @account.id, @pcp_subject.p_deputy_id
    assert_equal @account.id, @pcp_subject.s_owner_id

    assert_no_difference( 'PcpSubject.count', 'PcpStep.count' ) do
      patch :update, id: @pcp_subject, pcp_subject: {
      title: 'new title', note: 'new note',
      project_doc_id: 'new project doc id',
      report_doc_id: 'new report doc id' }
    end
    @pcp_subject = assigns( :pcp_subject )
    assert_redirected_to pcp_subject_path( @pcp_subject )
    assert_equal @pcp_subject.title, 'new title'
    assert_equal @pcp_subject.note, 'new note'
    assert_equal @pcp_subject.project_doc_id, 'new project doc id'
    assert_equal @pcp_subject.report_doc_id, 'new report doc id'

    # attempt to release - should fail

    assert_no_difference( 'PcpSubject.count', 'PcpStep.count' )do
      get :update_release, id: @pcp_subject
      assert_response :unprocessable_entity
    end
    
  end

end
