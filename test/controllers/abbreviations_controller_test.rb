require 'test_helper'
class AbbreviationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @abbreviation = abbreviations( :sag )
  end

  test 'check class_attributes'  do
    get abbreviations_path
    validate_feature_class_attributes FEATURE_ID_ABBREVIATIONS, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get abbreviations_path
    assert_response :success
    assert_not_nil assigns( :abbreviations )
  end

  test 'should get new' do
    get new_abbreviation_path
    assert_response :success
  end

  test 'should create abbreviation' do
    assert_difference( 'Abbreviation.count' ) do
      post abbreviations_path, params:{ abbreviation: { code: @abbreviation.code, description: @abbreviation.description }}
    end
    assert_redirected_to abbreviation_path( assigns( :abbreviation ))
  end

  test 'should show abbreviation' do
    get abbreviation_path( id: @abbreviation )
    assert_response :success
  end

  test 'should get edit' do
    get edit_abbreviation_path( id: @abbreviation )
    assert_response :success
  end

  test 'should update abbreviation' do
    patch abbreviation_path( id: @abbreviation, params:{ abbreviation: { code: @abbreviation.code, description: @abbreviation.description }})
    assert_redirected_to abbreviation_path( assigns( :abbreviation ))
  end

  test 'should destroy abbreviation' do
    assert_difference('Abbreviation.count', -1) do
      delete abbreviation_path( id: @abbreviation )
    end
    assert_redirected_to abbreviations_path
  end

  test 'CSV download' do
    get abbreviations_path( format: 'xls' )
    assert_equal <<END_OF_CSV, response.body
code;description;sort_code
PMO;Project Management Office;pmo
SAG;Siemens AG;sag
END_OF_CSV
  end

end
