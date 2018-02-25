require 'test_helper'
class A7CodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @a7_code = a7_codes(:one)
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get a7_codes_path
    validate_feature_class_attributes FEATURE_ID_A7_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get a7_codes_path
    assert_response :success
    assert_not_nil assigns( :a7_codes )
  end

  test 'should get new' do
    get new_a7_code_path
    assert_response :success
  end

  test 'should create a7_code' do
    assert_difference( 'A7Code.count' ) do
      post a7_codes_path, params:{ a7_code: { active: @a7_code.active, code: @a7_code.code, label: @a7_code.label, mapping: @a7_code.mapping, master: false }}
    end
    assert_redirected_to a7_code_path( assigns( :a7_code ))
  end

  test 'should show a7_code' do
    get a7_code_path( id: @a7_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_a7_code_path( id: @a7_code )
    assert_response :success
  end

  test 'should update a7_code' do
    patch a7_code_path( id: @a7_code ), params:{ a7_code: { active: @a7_code.active, code: @a7_code.code, label: @a7_code.label, mapping: @a7_code.mapping, master: @a7_code.master }}
    assert_redirected_to a7_code_path( assigns( :a7_code ))
  end

  test 'should destroy a7_code' do
    assert_difference( 'A7Code.count', -1 ) do
      delete a7_code_path( id: @a7_code )
    end
    assert_redirected_to a7_codes_path
  end
end
