require 'test_helper'
class RegionNamesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @region_name = region_names( :mvp )
  end

  test 'check class_attributes'  do
    get region_names_path
    validate_feature_class_attributes FEATURE_ID_REGION_NAMES, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get region_names_path
    assert_response :success
    assert_not_nil assigns( :region_names )
  end

  test 'should get new' do
    get new_region_name_path
    assert_response :success
  end

  test 'should create region_name' do
    assert_difference( 'RegionName.count' ) do
      post region_names_path( params:{ region_name: {
        code:            @region_name.code << 'a',
        country_name_id: @region_name.country_name_id,
        label:           @region_name.label }})
    end
    assert_redirected_to region_name_path( assigns( :region_name ))
  end

  test 'should show region_name' do
    get region_name_path( id: @region_name )
    assert_response :success
  end

  test 'should get edit' do
    get region_name_path( id: @region_name )
    assert_response :success
  end

  test 'should update region_name' do
    patch region_name_path( id: @region_name, params:{ region_name: {
      code:            @region_name.code,
      country_name_id: @region_name.country_name_id,
      label:           @region_name.label }})
    assert_redirected_to region_name_path( assigns( :region_name ))
  end

  test 'should destroy region_name' do
    assert_difference('RegionName.count', -1) do
      delete region_name_path( id: @region_name )
    end
    assert_redirected_to region_names_path
  end

end
