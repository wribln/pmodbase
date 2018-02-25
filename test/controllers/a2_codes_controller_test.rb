require 'test_helper'
class A2CodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @a2_code = a2_codes( :one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get a2_codes_path
    validate_feature_class_attributes FEATURE_ID_A2_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get a2_codes_path
    assert_response :success
    assert_not_nil assigns( :a2_codes )
  end

  test 'should get new' do
    get new_a2_code_path
    assert_response :success
  end

  test 'should create a2_code' do
    assert_difference( 'A2Code.count' ) do
      post a2_codes_path, params:{ a2_code: { active: @a2_code.active, code: @a2_code.code, label: @a2_code.label, mapping: @a2_code.mapping, master: false }}
    end
    assert_redirected_to a2_code_path( assigns( :a2_code ))
  end

  test 'should show a2_code' do
    get a2_code_path( id: @a2_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_a2_code_path( id: @a2_code )
    assert_response :success
  end

  test 'should update a2_code' do
    patch a2_code_path( id: @a2_code), params:{ a2_code: { active: @a2_code.active, code: @a2_code.code, label: @a2_code.label, mapping: @a2_code.mapping, master: @a2_code.master }}
    assert_redirected_to a2_code_path( assigns( :a2_code ))
  end

  test 'should destroy a2_code' do
    assert_difference( 'A2Code.count', -1 ) do
      delete a2_code_path( id: @a2_code )
    end
    assert_redirected_to a2_codes_path
  end
end
