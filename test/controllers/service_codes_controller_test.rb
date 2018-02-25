require 'test_helper'
class ServiceCodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @service_code = service_codes( :one )
  end

  test 'check class_attributes'  do
    get service_codes_path
    validate_feature_class_attributes FEATURE_ID_SERVICE_CODES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get service_codes_path
    assert_response :success
    assert_not_nil assigns( :service_codes )
  end

  test 'should get new' do
    get new_service_code_path
    assert_response :success
  end

  test 'should create service_code' do
    assert_difference( 'ServiceCode.count' ) do
      post service_codes_path, params:{ service_code: { code: @service_code.code, label: @service_code.label, master: false }}
    end
    assert_redirected_to service_code_path( assigns( :service_code ))
  end

  test 'should show service_code' do
    get service_code_path( id: @service_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_service_code_path( id: @service_code )
    assert_response :success
  end

  test 'should update service_code' do
    patch service_code_path( id: @service_code, params:{ service_code: { label: @service_code.label }})
    assert_redirected_to service_code_path( assigns( :service_code ))
  end

  test 'should destroy service_code' do
    assert_difference( 'ServiceCode.count', -1) do
      delete service_code_path( id: @service_code )
    end
    assert_redirected_to service_codes_path
  end
end
