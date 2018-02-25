require 'test_helper'
class A3CodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @a3_code = a3_codes( :one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get a3_codes_path
    validate_feature_class_attributes FEATURE_ID_A3_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get a3_codes_path
    assert_response :success
    assert_not_nil assigns( :a3_codes )
  end

  test 'should get new' do
    get new_a3_code_path
    assert_response :success
  end

  test 'should create a3_code' do
    assert_difference( 'A3Code.count' ) do
      post a3_codes_path, params:{ a3_code: { active: @a3_code.active, code: @a3_code.code, label: @a3_code.label, mapping: @a3_code.mapping, master: false }}
    end
    assert_redirected_to a3_code_path( assigns( :a3_code ))
  end

  test 'should show a3_code' do
    get a1_code_path( id: @a3_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_a1_code_path( id: @a3_code )
    assert_response :success
  end

  test 'should update a3_code' do
    patch a3_code_path( id: @a3_code ), params:{ a3_code: { active: @a3_code.active, code: @a3_code.code, label: @a3_code.label, mapping: @a3_code.mapping, master: @a3_code.master }}
    assert_redirected_to a3_code_path( assigns( :a3_code ))
  end

  test 'should destroy a3_code' do
    assert_difference( 'A3Code.count', -1 ) do
      delete a3_code_path( id: @a3_code )
    end
    assert_redirected_to a3_codes_path
  end
end
