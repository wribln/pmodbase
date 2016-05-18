require 'test_helper'
class PcpMembersController2Test < ActionController::TestCase
  tests PcpMembersController

  # ensure that only the owner/deputy of the viewing group can make
  # respective changes

  # test suite 1 - presenting group

  setup do
    @pcp_member = pcp_members( :one )
    @pcp_subject = pcp_subjects( :two )
    @account = accounts( :account_one )
    session[ :current_user_id ] = @account.id
  end

  test 'should get index' do
    get :index, pcp_subject_id: @pcp_subject
    assert_response :success
    @pcp_members = assigns( :pcp_members )
    assert 1, @pcp_members.count
    assert_equal @pcp_members[0].id, pcp_members( :one ).id
  end

  test 'should get new' do
    get :new, pcp_subject_id: @pcp_subject
    assert_response :success
  end

  test 'should create pcp_member' do
    assert_difference( 'PcpMember.count' ) do
      post :create, pcp_member: {
        account_id: accounts( :account_wop ),
        to_access: true },
        pcp_subject_id: @pcp_subject.id
    end
    @pcp_member_new = assigns( :pcp_member )
    assert_redirected_to pcp_member_path( @pcp_member_new )
    assert_equal 0, @pcp_member_new.pcp_group
  end

  test 'should show pcp_item' do
    get :show, id: @pcp_member
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @pcp_member
    assert_response :success
  end

  test 'should update pcp_member' do
    patch :update, id: @pcp_member, pcp_member: {
      to_access: false,
      to_update: false }
    assert_redirected_to pcp_member_path( assigns( :pcp_member ))
  end

  test 'should destroy pcp_member' do
    assert_difference('PcpMember.count', -1) do
      delete :destroy, id: @pcp_member
    end
    assert_redirected_to pcp_subject_pcp_members_path( @pcp_subject )
  end

end
