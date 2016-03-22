require 'test_helper'
class AbbreviationsControllerTest < ActionController::TestCase

  setup do
    session[ :current_user_id ] = accounts( :account_one ).id
    @abbreviation = abbreviations( :sag )
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_ABBREVIATIONS, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :abbreviations )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create abbreviation" do
    assert_difference('Abbreviation.count') do
      post :create, abbreviation: { code: @abbreviation.code, description: @abbreviation.description }
    end

    assert_redirected_to abbreviation_path( assigns( :abbreviation ))
  end

  test "should show abbreviation" do
    get :show, id: @abbreviation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @abbreviation
    assert_response :success
  end

  test "should update abbreviation" do
    patch :update, id: @abbreviation, abbreviation: { code: @abbreviation.code, description: @abbreviation.description }
    assert_redirected_to abbreviation_path( assigns( :abbreviation ))
  end

  test "should destroy abbreviation" do
    assert_difference('Abbreviation.count', -1) do
      delete :destroy, id: @abbreviation
    end
    assert_redirected_to abbreviations_path
  end

  test "CSV download" do
    get :index, format: 'xls'
    assert_equal <<END_OF_CSV, response.body
code;description;sort_code
PMO;Project Management Office;pmo
SAG;Siemens AG;sag
END_OF_CSV
  end

end
