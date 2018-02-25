require 'test_helper'
class CfrLocationTypesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @cfr_location_type = cfr_location_types( :one )
  end

  test 'check class_attributes'  do
    get cfr_location_types_path
    validate_feature_class_attributes FEATURE_ID_CFR_LOCATION_TYPES, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get cfr_location_types_path
    assert_response :success
    assert_not_nil assigns( :cfr_location_types )
  end

  test 'should get new' do
    get new_cfr_location_type_path
    assert_response :success
  end

  test 'should create cfr_location_type' do
    assert_difference('CfrLocationType.count') do
      post cfr_location_types_path, params:{ cfr_location_type: { label: @cfr_location_type.label, note: @cfr_location_type.note, project_dms: false }}
    end
    assert_redirected_to cfr_location_type_path( assigns( :cfr_location_type ))
  end

  test 'should show cfr_location_type' do
    get cfr_location_type_path( id: @cfr_location_type )
    assert_response :success
  end

  test 'should get edit' do
    get edit_cfr_location_type_path( id: @cfr_location_type )
    assert_response :success
  end

  test 'should update cfr_location_type' do
    patch cfr_location_type_path( id: @cfr_location_type, params:{ cfr_location_type: { concat_char: @cfr_location_type.concat_char, label: @cfr_location_type.label, note: @cfr_location_type.note, path_prefix: @cfr_location_type.path_prefix, project_dms: @cfr_location_type.project_dms }})
    assert_redirected_to cfr_location_type_path(assigns(:cfr_location_type))
  end

  test 'should destroy cfr_location_type' do
    assert_difference('CfrLocationType.count', -1) do
      delete cfr_location_type_path( id: @cfr_location_type )
    end
    assert_redirected_to cfr_location_types_path
  end

end
