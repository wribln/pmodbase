require 'test_helper'
class CountryNamesControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
    @country_name = country_names( :usa )
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_COUNTRY_NAMES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :country_names )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create country_name" do
    assert_difference('CountryName.count') do
      post :create, country_name: { code: @country_name.code + 'a', label: @country_name.label }
    end
    assert_redirected_to country_name_path( assigns( :country_name ))
  end

  test "should show country_name" do
    get :show, id: @country_name
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @country_name
    assert_response :success
  end

  test "should update country_name" do
    patch :update, id: @country_name, country_name: { code: @country_name.code + 'a' }
    assert_redirected_to country_name_path( assigns( :country_name ))
  end

  test "should destroy country_name" do
    assert_difference('CountryName.count', -1) do
      delete :destroy, id: @country_name
    end

    assert_redirected_to country_names_path
  end
end
