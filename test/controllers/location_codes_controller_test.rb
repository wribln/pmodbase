require 'test_helper'
class LocationCodesControllerTest < ActionController::TestCase

  setup do
    @location_code = location_codes( :two )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :location_codes )
  end

  test 'should validate all' do
    get :update_check
    assert_response :success
    assert_not_nil assigns( :location_codes )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create location_code' do
    assert_difference( 'LocationCode.count' ) do
      post :create, location_code: { code: @location_code.code + '.', label: 'test', loc_type: 0 }
    end
    assert_redirected_to location_code_path( assigns( :location_code ))
  end

  test 'should show location_code' do
    get :show, id: @location_code
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @location_code
    assert_response :success
  end

  test 'should update location_code' do
    patch :update, id: @location_code, location_code: { center_point: @location_code.center_point, code: @location_code.code, end_point: @location_code.end_point, length: @location_code.length, loc_type: @location_code.loc_type, remarks: @location_code.remarks, start_point: @location_code.start_point }
    assert_redirected_to location_code_path(assigns( :location_code ))
  end

  test 'should destroy location_code' do
    assert_difference('LocationCode.count', -1) do
      delete :destroy, id: @location_code
    end
    assert_redirected_to location_codes_path
  end
end
