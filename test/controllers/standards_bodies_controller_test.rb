require 'test_helper'
class StandardsBodiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @standards_body = standards_bodies( :din )
  end

  test 'check class_attributes'  do
    get standards_bodies_path
    validate_feature_class_attributes FEATURE_ID_STANDARDS_BODIES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get standards_bodies_path
    assert_response :success
    assert_not_nil assigns( :standards_bodies )
  end

  test 'should get new' do
    get new_standards_body_path
    assert_response :success
  end

  test 'should create standards_body' do
    assert_difference( 'StandardsBody.count' ) do
      post standards_bodies_path, params:{ standards_body: { code: @standards_body.code << 'a', description: @standards_body.description }}
    end
    assert_redirected_to standards_body_path( assigns( :standards_body ))
  end

  test 'should show standards_body' do
    get standards_body_path( id: @standards_body )
    assert_response :success
  end

  test 'should get edit' do
    get edit_standards_body_path( id: @standards_body )
    assert_response :success
  end

  test 'should update standards_body' do
    patch standards_body_path( id: @standards_body, params:{ standards_body: { code: @standards_body.code, description: @standards_body.description }})
    assert_redirected_to standards_body_path( assigns( :standards_body ))
  end

  test 'should destroy standards_body' do
    assert_difference('StandardsBody.count', -1) do
      delete standards_body_path( id: @standards_body )
    end
    assert_redirected_to standards_bodies_path
  end

  test 'CSV download' do
    get standards_bodies_path( format: :xls )
    assert_equal <<END_OF_CSV, response.body
code,description
DIN,Deutsches Institut für Normung (German: German Institute for Standardization)
ISO,name of the International Organization for Standardization
END_OF_CSV
  end

end
