require 'test_helper'
class A8CodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @a8_code = a8_codes(:one)
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get a8_codes_path
    validate_feature_class_attributes FEATURE_ID_A8_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get a8_codes_path
    assert_response :success
    assert_not_nil assigns( :a8_codes )
  end

  test 'should get new' do
    get new_a8_code_path
    assert_response :success
  end

  test 'should create a8_code' do
    assert_difference( 'A8Code.count' ) do
      post a8_codes_path, params:{ a8_code: { active: @a8_code.active, code: @a8_code.code, label: @a8_code.label, mapping: @a8_code.mapping, master: false }}
    end
    assert_redirected_to a8_code_path( assigns( :a8_code ))
  end

  test 'should show a8_code' do
    get a8_code_path( id: @a8_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_a8_code_path( id: @a8_code )
    assert_response :success
  end

  test 'should update a8_code' do
    patch a8_code_path( id: @a8_code ), params:{ a8_code: { active: @a8_code.active, code: @a8_code.code, label: @a8_code.label, mapping: @a8_code.mapping, master: @a8_code.master }}
    assert_redirected_to a8_code_path( assigns( :a8_code ))
  end

  test 'should destroy a8_code' do
    assert_difference( 'A8Code.count', -1 ) do
      delete a8_code_path( id: @a8_code )
    end
    assert_redirected_to a8_codes_path
  end
end
