require 'test_helper'
class PcpSubjectsController3Test < ActionController::TestCase
  tests PcpSubjectsController

  # user must have group permission for p_group_id of
  # PCP Category in order to create a PCP Subject for
  # that PCP Category

  setup do 
    @pcp_category = pcp_categories( :one )
    @account_id = accounts( :account_wop ).id
    session[ :current_user_id ] = @account_id
  end

  test 'user has not access' do
    # see test case in pcp_subjects_controller_1_test.rb
  end

  test 'user has access for different group' do
    g = Group.new(
      code: 'FOO',
      label: 'bar',
      group_category_id: group_categories( :group_category_one ).id )
    assert g.save, g.errors.inspect
    p = Permission4Group.new( 
      account_id: @account_id,
      feature_id: FEATURE_ID_PCP_SUBJECTS,
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
      account_id: @account_id,
      feature_id: FEATURE_ID_PCP_SUBJECTS,
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
      account_id: @account_id,
      feature_id: FEATURE_ID_PCP_SUBJECTS,
      group_id: @pcp_category.p_group_id,
      to_index: 1, to_create: 1, to_read: 1, to_update: 1 )
    assert p.save, p.errors.inspect
    #
    p = PcpSubject.new( pcp_category_id: @pcp_category.id )
    assert p.permitted_to_create?( accounts( :account_wop ))
    assert_difference( 'PcpSubject.count', 1 ) do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_category.id,
        title: 'very foobar' }
    end
    @pcp_subject = assigns( :pcp_subject )
    assert_redirected_to pcp_subject_path( @pcp_subject )
    
    # user is now owner of this subject and can change the group
    # and the category assignment

    # first attempt will fail as user has no access to current group

    assert accounts( :account_wop ).id, @pcp_subject.p_owner_id

    g = Group.new(
      code: 'FOO',
      label: 'bar',
      group_category_id: group_categories( :group_category_one ).id )
    assert g.save, g.errors.inspect
    patch :update, id: @pcp_subject, pcp_subject: { p_group_id: g.id } 
    assert_response :success
    s = assigns( :pcp_subject )
    refute_nil s
    assert_includes s.errors, :p_owner_id

    # give user access to subject's group

    p = Permission4Group.new( 
      account_id: @account_id,
      feature_id: FEATURE_ID_PCP_SUBJECTS,
      group_id: g.id,
      to_index: 1, to_create: 1, to_read: 1, to_update: 1 )
    assert p.save, p.errors.inspect
    #
    patch :update, id: @pcp_subject, pcp_subject: { p_group_id: g.id }
    assert_redirected_to pcp_subject_path( assigns( :pcp_subject ))

    # make new category to continue test

    c = @pcp_category.dup
    c.label = 'Other Category'
    assert c.save, c.errors.inspect
    #
    patch :update, id: @pcp_subject, pcp_subject: { pcp_category_id: c.id }
    assert_redirected_to pcp_subject_path( assigns( :pcp_subject ))

    # insert here a test to try accessing the current release (there
    # is none)

    get :show_release, id: @pcp_subject, step_no: 0
    assert_response :not_found

  end

end
