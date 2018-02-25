require 'test_helper'
class A4CodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @a4_code = a4_codes(:one)
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get a4_codes_path
    validate_feature_class_attributes FEATURE_ID_A4_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get a4_codes_path
    assert_response :success
    assert_not_nil assigns( :a4_codes )
  end

  test 'should get new' do
    get new_a4_code_path
    assert_response :success
  end

  test 'should create a4_code' do
    assert_difference( 'A4Code.count' ) do
      post a4_codes_path, params:{ a4_code: { active: @a4_code.active, code: @a4_code.code, label: @a4_code.label, mapping: @a4_code.mapping, master: false }}
    end
    assert_redirected_to a4_code_path( assigns( :a4_code ))
  end

  test 'should show a4_code' do
    get a4_code_path( id: @a4_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_a4_code_path( id: @a4_code )
    assert_response :success
  end

  test 'should update a4_code' do
    patch a4_code_path( id: @a4_code ), params:{ a4_code: { active: @a4_code.active, code: @a4_code.code, label: @a4_code.label, mapping: @a4_code.mapping, master: @a4_code.master }}
    assert_redirected_to a4_code_path( assigns( :a4_code ))
  end

  test 'should destroy a4_code' do
    assert_difference( 'A4Code.count', -1 ) do
      delete a4_code_path( id: @a4_code )
    end
    assert_redirected_to a4_codes_path
  end
end
