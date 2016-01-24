require 'test_helper'
class OurTiaMembersControllerTest < ActionController::TestCase
  
  setup do
    @tia_member = tia_members( :one )
    @tia_list = @tia_member.tia_list
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "should get index" do
    get :index, my_tia_list_id: @tia_list
    assert_response :success
    assert_not_nil assigns( :tia_members )
  end

  test "should get new" do
    get :new, my_tia_list_id: @tia_list
    assert_response :success
  end

  test "should create tia_member" do
    assert_difference('TiaMember.count') do
      post :create, tia_member: {
        account_id: accounts( :account_three ).id,
        to_access:  true },
        my_tia_list_id: @tia_list
    end
    assert_redirected_to our_tia_member_path( assigns( :tia_member ))
  end

  test "should show tia_member" do
    get :show, id: @tia_member
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tia_member
    assert_response :success
  end

  test "should update tia_member" do
    patch :update, id: @tia_member, tia_member: { to_access: true }, my_tia_list_id: @tia_list
    assert_redirected_to our_tia_member_path( assigns( :tia_member ))
  end

  test "should destroy tia_member" do
    assert_difference('TiaMember.count', -1) do
      delete :destroy, id: @tia_member
    end
    assert_redirected_to my_tia_list_our_tia_members_path( @tia_list )
  end
end
