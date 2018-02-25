require 'test_helper'
class A6CodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @a6_code = a6_codes( :one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get a6_codes_path
    validate_feature_class_attributes FEATURE_ID_A6_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get a6_codes_path
    assert_response :success
    assert_not_nil assigns( :a6_codes )
  end

  test 'should get new' do
    get new_a6_code_path
    assert_response :success
  end

  test 'should create a6_code' do
    assert_difference( 'A6Code.count' ) do
      post a6_codes_path, params:{ a6_code: { active: @a6_code.active, code: @a6_code.code, label: @a6_code.label, mapping: @a6_code.mapping, master: false }}
    end
    assert_redirected_to a6_code_path( assigns( :a6_code ))
  end

  test 'should show a6_code' do
    get a6_code_path( id: @a6_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_a6_code_path( id: @a6_code )
    assert_response :success
  end

  test 'should update a6_code' do
    patch a6_code_path( id: @a6_code ), params:{ a6_code: { active: @a6_code.active, code: @a6_code.code, label: @a6_code.label, mapping: @a6_code.mapping, master: @a6_code.master }}
    assert_redirected_to a6_code_path( assigns( :a6_code ))
  end

  test 'should destroy a6_code' do
    assert_difference( 'A6Code.count', -1 ) do
      delete a6_code_path( id: @a6_code )
    end
    assert_redirected_to a6_codes_path
  end
end
