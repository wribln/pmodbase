require 'test_helper'
class CountryNamesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @country_name = country_names( :usa )
  end

  test 'check class_attributes'  do
    get country_names_path
    validate_feature_class_attributes FEATURE_ID_COUNTRY_NAMES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get country_names_path
    assert_response :success
    assert_not_nil assigns( :country_names )
  end

  test 'should get new' do
    get new_country_name_path
    assert_response :success
  end

  test 'should create country_name' do
    assert_difference('CountryName.count') do
      post country_names_path, params:{ country_name: { code: @country_name.code + 'a', label: @country_name.label }}
    end
    assert_redirected_to country_name_path( assigns( :country_name ))
  end

  test 'should show country_name' do
    get country_name_path( id: @country_name )
    assert_response :success
  end

  test 'should get edit' do
    get edit_country_name_path( id: @country_name )
    assert_response :success
  end

  test 'should update country_name' do
    patch country_name_path( id: @country_name, params:{ country_name: { code: @country_name.code + 'a' }})
    assert_redirected_to country_name_path( assigns( :country_name ))
  end

  test 'should destroy country_name' do
    assert_difference('CountryName.count', -1) do
      delete country_name_path( id: @country_name )
    end
    assert_redirected_to country_names_path
  end
end
