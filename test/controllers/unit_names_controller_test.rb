require 'test_helper'
class UnitNamesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @unit_name = unit_names( :one )
  end

  test 'check class_attributes'  do
    get unit_names_path
    validate_feature_class_attributes FEATURE_ID_UNIT_NAMES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get unit_names_path
    assert_response :success
    assert_not_nil assigns( :unit_names )
  end

  test 'should get new' do
    get new_unit_name_path
    assert_response :success
  end

  test 'should create unit_name' do
    assert_difference( 'UnitName.count' ) do
      post unit_names_path, params:{ unit_name:{ code: @unit_name.code, label: @unit_name.label }}
    end
    assert_redirected_to unit_name_path(assigns(:unit_name))
  end

  test 'should show unit_name' do
    get unit_name_path( id: @unit_name )
    assert_response :success
  end

  test 'should get edit' do
    get edit_unit_name_path( id: @unit_name )
    assert_response :success
  end

  test 'should update unit_name' do
    patch unit_name_path( id: @unit_name, params:{ unit_name:{ code: @unit_name.code, label: @unit_name.label }})
    assert_redirected_to unit_name_path(assigns(:unit_name))
  end

  test 'should destroy unit_name' do
    assert_difference('UnitName.count', -1) do
      delete unit_name_path( id: @unit_name )
    end

    assert_redirected_to unit_names_path
  end

  test 'CSV download' do
    get unit_names_path( format: :xls )
    assert_equal <<END_OF_CSV, response.body
code;label
jau;just another unit
END_OF_CSV
  end

end
