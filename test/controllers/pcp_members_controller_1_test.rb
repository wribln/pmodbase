require 'test_helper'
class PcpMembersController1Test < ActionController::TestCase
  tests PcpMembersController

  # test access to PCP Members for a user without any permissions

  setup do
    @pcp_member = pcp_members( :one )
    @pcp_subject = @pcp_member.pcp_subject
    @account = accounts( :account_three )
    session[ :current_user_id ] = @account.id
  end

  test 'should get index' do
    get :index, pcp_subject_id: @pcp_subject
    assert_response :forbidden
  end

  test 'should get new' do
    get :new, pcp_subject_id: @pcp_subject
    assert_response :forbidden
  end

  test 'should create pcp_member' do
    assert_no_difference( 'PcpMember.count' ) do
      post :create, pcp_member: {
        account_id: accounts( :account_three ),
        pcp_group: 0,
        to_access: true },
        pcp_subject_id: @pcp_subject.id
    end
    assert_response :forbidden
  end

  test 'should show pcp_item' do
    get :show, id: @pcp_member
    assert_response :forbidden
  end

  test 'should get edit' do
    get :edit, id: @pcp_member
    assert_response :forbidden
  end

  test 'should update pcp_member' do
    patch :update, id: @pcp_member, pcp_member: {
      to_access: false,
      to_update: false }
    assert_response :forbidden
  end

  test 'should destroy pcp_member' do
    assert_no_difference('PcpMember.count', -1) do
      delete :destroy, id: @pcp_member
    end
    assert_response :forbidden
  end

end
