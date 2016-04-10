require 'test_helper'

class OrlTypesControllerTest < ActionController::TestCase
  setup do
    @orl_type = orl_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orl_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create orl_type" do
    assert_difference('OrlType.count') do
      post :create, orl_type: { label: @orl_type.label, o_group_id: @orl_type.o_group_id, r_group_id: @orl_type.r_group_id }
    end

    assert_redirected_to orl_type_path(assigns(:orl_type))
  end

  test "should show orl_type" do
    get :show, id: @orl_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @orl_type
    assert_response :success
  end

  test "should update orl_type" do
    patch :update, id: @orl_type, orl_type: { label: @orl_type.label, o_group_id: @orl_type.o_group_id, r_group_id: @orl_type.r_group_id }
    assert_redirected_to orl_type_path(assigns(:orl_type))
  end

  test "should destroy orl_type" do
    assert_difference('OrlType.count', -1) do
      delete :destroy, id: @orl_type
    end

    assert_redirected_to orl_types_path
  end
end
