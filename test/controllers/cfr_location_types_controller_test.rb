require 'test_helper'
class CfrLocationTypesControllerTest < ActionController::TestCase

  setup do
    @cfr_location_type = cfr_location_types( :one )
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_CFR_LOCATION_TYPES, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :cfr_location_types )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create cfr_location_type' do
    assert_difference('CfrLocationType.count') do
      post :create, cfr_location_type: { label: @cfr_location_type.label, note: @cfr_location_type.note, project_dms: false }
    end
    assert_redirected_to cfr_location_type_path( assigns( :cfr_location_type ))
  end

  test 'should show cfr_location_type' do
    get :show, id: @cfr_location_type
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @cfr_location_type
    assert_response :success
  end

  test 'should update cfr_location_type' do
    patch :update, id: @cfr_location_type, cfr_location_type: { concat_char: @cfr_location_type.concat_char, label: @cfr_location_type.label, note: @cfr_location_type.note, path_prefix: @cfr_location_type.path_prefix, project_dms: @cfr_location_type.project_dms }
    assert_redirected_to cfr_location_type_path(assigns(:cfr_location_type))
  end

  test 'should destroy cfr_location_type' do
    assert_difference('CfrLocationType.count', -1) do
      delete :destroy, id: @cfr_location_type
    end
    assert_redirected_to cfr_location_types_path
  end

end
