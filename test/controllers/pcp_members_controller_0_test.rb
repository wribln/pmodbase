require 'test_helper'
class PcpMembersController0Test < ActionDispatch::IntegrationTest

  setup do
    @pcp_member = pcp_members( :one )
    @pcp_subject = @pcp_member.pcp_subject
    signon_by_user accounts( :one )
  end

  test 'check class attributes' do
    get pcp_subject_pcp_members_path( pcp_subject_id: @pcp_subject )
    validate_feature_class_attributes FEATURE_ID_PCP_MEMBERS, ApplicationController::FEATURE_ACCESS_USER + ApplicationController::FEATURE_ACCESS_NBP, ApplicationController::FEATURE_CONTROL_CUG
  end

  test 'should get index' do
    get pcp_subject_pcp_members_path( pcp_subject_id: @pcp_subject )
    assert_response :success
    assert_not_nil assigns( :pcp_members )
  end

  test 'should get new' do
    get new_pcp_subject_pcp_member_path( pcp_subject_id: @pcp_subject )
    assert_response :success
  end

  test 'should create pcp_member' do
    assert_difference( 'PcpMember.count' ) do
      post pcp_subject_pcp_members_path( pcp_subject_id: @pcp_subject.id, params:{ pcp_member: {
        account_id: accounts( :wop ),
        pcp_group: 0,
        to_access: true }})
    end
    assert_redirected_to pcp_member_path( assigns( :pcp_member ))
  end

  test 'should show pcp_item' do
    get pcp_member_path( id: @pcp_member )
    assert_response :success
  end

  test 'should get edit' do
    get edit_pcp_member_path( id: @pcp_member )
    assert_response :success
  end

  test 'should update pcp_member' do
    patch pcp_member_path( id: @pcp_member, params:{ pcp_member: {
      to_access: false,
      to_update: false }})
    assert_redirected_to pcp_member_path( assigns( :pcp_member ))
  end

  test 'should destroy pcp_member' do
    assert_difference('PcpMember.count', -1) do
      delete pcp_member_path( id: @pcp_member )
    end
    assert_redirected_to pcp_subject_pcp_members_path( @pcp_subject )
  end

end
