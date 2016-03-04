require 'test_helper'
class PhaseCodesControllerTest < ActionController::TestCase

  setup do
    @person = people( :person_one )
    session[ :current_user_id ] = accounts( :account_one ).id
    
    @phase_code_test = phase_codes( :prl )
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_PHASE_CODES, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "ensure consistency of test data" do
    assert_not_nil @phase_code_test.code
    assert_not_nil @phase_code_test.label
    assert_not_nil @phase_code_test.acro
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :phase_codes )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create phase_code" do
    assert_difference( 'PhaseCode.count' ) do
      post :create, phase_code: { 
        acro: @phase_code_test.acro + 'X',
        code: @phase_code_test.code + 'X',
        siemens_phase_id: @phase_code_test.siemens_phase_id,
        label: @phase_code_test.label }
    end

    assert_redirected_to phase_code_path( assigns( :phase_code ))
  end

  test "should show phase_code" do
    get :show, id: @phase_code_test
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @phase_code_test
    assert_response :success
  end

  test "should update phase_code" do
    patch :update, id: @phase_code_test, phase_code: {
      acro: @phase_code_test.acro,
      code: @phase_code_test.code,
      siemens_phase_id: @phase_code_test.siemens_phase_id,
      label: @phase_code_test.label,
      level: @phase_code_test.level }
    assert_redirected_to phase_code_path( assigns( :phase_code ))
  end

  test "should destroy phase_code" do
    assert_difference('PhaseCode.count', -1) do
      delete :destroy, id: @phase_code_test
    end

    assert_redirected_to phase_codes_path
  end
end
