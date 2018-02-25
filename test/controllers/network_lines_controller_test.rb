require 'test_helper'
class NetworkLinesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @network_line = network_lines( :one )
    signon_by_user accounts( :one )
  end

  test 'check class attributes' do
    get network_lines_path
    validate_feature_class_attributes FEATURE_ID_NW_LINES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get network_lines_path
    assert_response :success
    assert_not_nil assigns(:network_lines)
  end

  test 'should get new' do
    get new_network_line_path
    assert_response :success
  end

  test 'should create network_line' do
    assert_difference('NetworkLine.count') do
      post network_lines_path( params:{ network_line: { code: @network_line.code + 'x', label: @network_line.label, location_code_id: @network_line.location_code_id }})
    end
    assert_redirected_to network_line_path(assigns(:network_line))
  end

  test 'should show network_line' do
    get network_line_path( id: @network_line )
    assert_response :success
  end

  test 'should get edit' do
    get edit_network_line_path( id: @network_line )
    assert_response :success
  end

  test 'should update network_line' do
    patch network_line_path( id: @network_line, params:{ network_line: { label: @network_line.label }})
    assert_redirected_to network_line_path(assigns(:network_line))
  end

  test 'should destroy network_line' do
    assert_difference('NetworkLine.count', -1) do
      delete network_line_path( id: @network_line )
    end
    assert_redirected_to network_lines_path
  end

end
