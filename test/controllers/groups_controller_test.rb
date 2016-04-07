require 'test_helper'
class GroupsControllerTest < ActionController::TestCase

  setup do
    @group = groups( :group_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_GROUPS, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group" do
    assert_difference( 'Group.count' )do
      post :create, group: { code: @group.code << 'a', label: @group.label, group_category_id: @group.group_category_id }
    end

    assert_redirected_to group_path( assigns( :group ))
  end

  test "should show group" do
    get :show, id: @group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group
    assert_response :success
  end

  test "should update group" do
    patch :update, id: @group, group: { label: @group.label, code: @group.code }
    assert_redirected_to group_path(assigns(:group))
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, id: @group
    end

    assert_redirected_to groups_path
  end
  
  test "CSV download" do
    get :index, format: :xls
    assert_equal <<END_OF_CSV, response.body
code;label;notes;seqno;group_category;sub_group_of;participating;s_sender_code;s_receiver_code;active;standard
TWO;Group 2;"";0;Group Category 1;Group 1;true;true;true;true;true
ONE;Group 1;"";0;Group Category 1;;true;true;true;true;true
END_OF_CSV
  end

end
