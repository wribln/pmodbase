require 'test_helper'
class SiemensPhasesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @person = people( :person_one )
    @siemens_phase = siemens_phases( :pm200 )
  end

  test 'check class_attributes'  do
    get siemens_phases_path
    validate_feature_class_attributes FEATURE_ID_SIEMENS_PHASES, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get siemens_phases_path
    assert_response :success
    assert_not_nil assigns( :siemens_phases )
  end

  test 'should get new' do
    get new_siemens_phase_path
    assert_response :success
  end

  test 'should create siemens_phase' do
    assert_difference('SiemensPhase.count') do
      post siemens_phases_path, params:{ siemens_phase:{ code: @siemens_phase.code + '.', label_p: @siemens_phase.label_p, label_m: @siemens_phase.label_m }}
    end
    assert_redirected_to siemens_phase_path( assigns( :siemens_phase ))
  end

  test 'should show siemens_phase' do
    get siemens_phase_path( id: @siemens_phase )
    assert_response :success
  end

  test 'should get edit' do
    get edit_siemens_phase_path( id: @siemens_phase )
    assert_response :success
  end

  test 'should update siemens_phase' do
    patch siemens_phase_path( id: @siemens_phase, params:{ siemens_phase:{ code: @siemens_phase.code, label_p: @siemens_phase.label_p, label_m: @siemens_phase.label_m }})
    assert_redirected_to siemens_phase_path( assigns( :siemens_phase ))
  end

  test 'should destroy siemens_phase' do
    assert_difference('SiemensPhase.count', -1) do
      delete siemens_phase_path( id: @siemens_phase )
    end
    assert_redirected_to siemens_phases_path
  end
end
