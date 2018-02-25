require 'test_helper'
class PhaseCodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @person = people( :person_one )
    @phase_code_test = phase_codes( :prl )
  end

  test 'check class_attributes'  do
    get phase_codes_path
    validate_feature_class_attributes FEATURE_ID_PHASE_CODES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'ensure consistency of test data' do
    assert_not_nil @phase_code_test.code
    assert_not_nil @phase_code_test.label
    assert_not_nil @phase_code_test.acro
  end

  test 'should get index' do
    get phase_codes_path
    assert_response :success
    assert_not_nil assigns( :phase_codes )
  end

  test 'should get new' do
    get new_phase_code_path
    assert_response :success
  end

  test 'should create phase_code' do
    assert_difference( 'PhaseCode.count' ) do
      post phase_codes_path( params:{ phase_code: { 
        acro: @phase_code_test.acro + 'X',
        code: @phase_code_test.code + 'X',
        siemens_phase_id: @phase_code_test.siemens_phase_id,
        label: @phase_code_test.label }})
    end
    assert_redirected_to phase_code_path( assigns( :phase_code ))
  end

  test 'should show phase_code' do
    get phase_code_path( id: @phase_code_test )
    assert_response :success
  end

  test 'should get edit' do
    get edit_phase_code_path( id: @phase_code_test )
    assert_response :success
  end

  test 'should update phase_code' do
    patch phase_code_path( id: @phase_code_test, params:{ phase_code: {
      acro: @phase_code_test.acro,
      code: @phase_code_test.code,
      siemens_phase_id: @phase_code_test.siemens_phase_id,
      label: @phase_code_test.label,
      level: @phase_code_test.level }})
    assert_redirected_to phase_code_path( assigns( :phase_code ))
  end

  test 'should destroy phase_code' do
    assert_difference('PhaseCode.count', -1) do
      delete phase_code_path( id: @phase_code_test )
    end
    assert_redirected_to phase_codes_path
  end

end
