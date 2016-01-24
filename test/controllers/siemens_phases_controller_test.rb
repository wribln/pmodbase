require 'test_helper'
class SiemensPhasesControllerTest < ActionController::TestCase

  setup do
    @person = people( :person_one )
    session[ :current_user_id ] = accounts( :account_one ).id
    @siemens_phase = siemens_phases( :pm200 )
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_SIEMENS_PHASES, ApplicationController::FEATURE_ACCESS_SOME
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :siemens_phases )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create siemens_phase" do
    assert_difference('SiemensPhase.count') do
      post :create, siemens_phase: {
        code: @siemens_phase.code + 'a',
        label_p: @siemens_phase.label_p,
        label_m: @siemens_phase.label_m }
    end

    assert_redirected_to siemens_phase_path( assigns( :siemens_phase ))
  end

  test "should show siemens_phase" do
    get :show, id: @siemens_phase
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @siemens_phase
    assert_response :success
  end

  test "should update siemens_phase" do
    patch :update, id: @siemens_phase, siemens_phase:{
      code: @siemens_phase.code,
      label_p: @siemens_phase.label_p,
      label_m: @siemens_phase.label_m }
    assert_redirected_to siemens_phase_path( assigns( :siemens_phase ))
  end

  test "should destroy siemens_phase" do
    assert_difference('SiemensPhase.count', -1) do
      delete :destroy, id: @siemens_phase
    end

    assert_redirected_to siemens_phases_path
  end
end
