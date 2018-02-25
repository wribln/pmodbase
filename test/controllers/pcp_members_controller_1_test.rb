require 'test_helper'
class PcpMembersController1Test < ActionDispatch::IntegrationTest

  # test access to PCP Members for a user without any permissions

  setup do
    @pcp_member = pcp_members( :one )
    @pcp_subject = @pcp_member.pcp_subject
    signon_by_user accounts( :three )
  end

  test 'should get index' do
    get pcp_subject_pcp_members_path( pcp_subject_id: @pcp_subject )
    assert_response :forbidden
  end

  test 'should get new' do
    get new_pcp_subject_pcp_member_path( pcp_subject_id: @pcp_subject )
    assert_response :forbidden
  end

  test 'should create pcp_member' do
    assert_no_difference( 'PcpMember.count' ) do
      post pcp_subject_pcp_members_path( pcp_subject_id: @pcp_subject.id, params:{ pcp_member: {
        account_id: accounts( :three ),
        pcp_group: 0,
        to_access: true }})
    end
    assert_response :forbidden
  end

  test 'should show pcp_item' do
    get pcp_member_path( id: @pcp_member )
    assert_response :forbidden
  end

  test 'should get edit' do
    get edit_pcp_member_path( id: @pcp_member )
    assert_response :forbidden
  end

  test 'should update pcp_member' do
    patch pcp_member_path( id: @pcp_member, params:{ pcp_member: {
      to_access: false,
      to_update: false }})
    assert_response :forbidden
  end

  test 'should destroy pcp_member' do
    assert_no_difference('PcpMember.count', -1) do
      delete pcp_member_path( id: @pcp_member )
    end
    assert_response :forbidden
  end

end
