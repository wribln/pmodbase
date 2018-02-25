require 'test_helper'
class DccCodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @dcc_code = dcc_codes( :one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get dcc_codes_path
    validate_feature_class_attributes FEATURE_ID_DCC_CODES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get dcc_codes_path
    assert_response :success
    assert_not_nil assigns( :dcc_codes )
  end

  test 'should get new' do
    get new_dcc_code_path
    assert_response :success
  end

  test 'should create dcc_code' do
    assert_difference( 'DccCode.count' ) do
      post dcc_codes_path( params:{ dcc_code: { code: @dcc_code.code, label: @dcc_code.label, master: false }})
    end
    assert_redirected_to dcc_code_path( assigns( :dcc_code ))
  end

  test 'should show dcc_code' do
    get dcc_code_path( id: @dcc_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_dcc_code_path( id: @dcc_code )
    assert_response :success
  end

  test 'should update dcc_code' do
    patch dcc_code_path(id: @dcc_code, params:{ dcc_code: { label: @dcc_code.label }})
    assert_redirected_to dcc_code_path( assigns( :dcc_code ))
  end

  test 'should destroy dcc_code' do
    assert_difference( 'DccCode.count', -1) do
      delete dcc_code_path( id: @dcc_code )
    end
    assert_redirected_to dcc_codes_path
  end
end
