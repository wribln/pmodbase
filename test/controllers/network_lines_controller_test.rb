require 'test_helper'
class NetworkLinesControllerTest < ActionController::TestCase

  setup do
    @network_line = network_lines( :one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class attributes" do
    validate_feature_class_attributes FEATURE_ID_NW_LINES, 
      ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:network_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create network_line" do
    assert_difference('NetworkLine.count') do
      post :create, network_line: { code: @network_line.code + 'x', label: @network_line.label, location_code_id: @network_line.location_code_id }
    end
    assert_redirected_to network_line_path(assigns(:network_line))
  end

  test "should show network_line" do
    get :show, id: @network_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @network_line
    assert_response :success
  end

  test "should update network_line" do
    patch :update, id: @network_line, network_line: { label: @network_line.label }
    assert_redirected_to network_line_path(assigns(:network_line))
  end

  test "should destroy network_line" do
    assert_difference('NetworkLine.count', -1) do
      delete :destroy, id: @network_line
    end
    assert_redirected_to network_lines_path
  end

end
