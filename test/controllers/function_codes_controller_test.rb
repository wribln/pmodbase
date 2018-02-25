require 'test_helper'
class FunctionCodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @function_code = function_codes( :one )
    signon_by_user accounts( :one )
  end

  test 'should get index' do
    get function_codes_path
    assert_response :success
    assert_not_nil assigns( :function_codes )
  end

  test 'should get new' do
    get new_function_code_path
    assert_response :success
  end

  test 'should create function_code' do
    assert_difference( 'FunctionCode.count' ) do
      post function_codes_path( params:{ function_code: { code: @function_code.code, label: @function_code.label, master: false }})
    end
    assert_redirected_to function_code_path( assigns( :function_code ))
  end

  test 'should show function_code' do
    get function_code_path( id: @function_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_function_code_path( id: @function_code )
    assert_response :success
  end

  test 'should update function_code' do
    patch function_code_path( id: @function_code, params:{ function_code: { label: @function_code.label }})
    assert_redirected_to function_code_path( assigns( :function_code ))
  end

  test 'should destroy function_code' do
    assert_difference( 'FunctionCode.count', -1) do
      delete function_code_path( id: @function_code )
    end
    assert_redirected_to function_codes_path
  end
end
