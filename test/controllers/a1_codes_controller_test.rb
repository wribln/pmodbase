require 'test_helper'
class A1CodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @a1_code = a1_codes( :one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get a1_codes_path
    validate_feature_class_attributes FEATURE_ID_A1_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get a1_codes_path
    assert_response :success
    assert_not_nil assigns( :a1_codes )
  end

  test 'should get new' do
    get new_a1_code_path
    assert_response :success
  end

  test 'should create a1_code' do
    assert_difference( 'A1Code.count' ) do
      post a1_codes_path, params:{ a1_code: { active: @a1_code.active, code: @a1_code.code, label: @a1_code.label, mapping: @a1_code.mapping, master: false }}
    end
    assert_redirected_to a1_code_path( assigns( :a1_code ))
  end

  test 'should show a1_code' do
    get a1_code_path( id: @a1_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_a1_code_path( id: @a1_code )
    assert_response :success
  end

  test 'should update a1_code' do
    patch a1_code_path( id: @a1_code ), params:{ a1_code: { active: @a1_code.active, code: @a1_code.code, label: @a1_code.label, mapping: @a1_code.mapping, master: @a1_code.master }}
    assert_redirected_to a1_code_path( assigns( :a1_code ))
  end

  test 'should destroy a1_code' do
    assert_difference( 'A1Code.count', -1 ) do
      delete a1_code_path( id: @a1_code )
    end
    assert_redirected_to a1_codes_path
  end
end
