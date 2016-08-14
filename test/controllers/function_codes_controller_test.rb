require 'test_helper'
class FunctionCodesControllerTest < ActionController::TestCase

  setup do
    @function_code = function_codes( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :function_codes )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create function_code' do
    assert_difference( 'FunctionCode.count' ) do
      post :create, function_code: { code: @function_code.code, label: @function_code.label, master: false }
    end
    assert_redirected_to function_code_path( assigns( :function_code ))
  end

  test 'should show function_code' do
    get :show, id: @function_code
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @function_code
    assert_response :success
  end

  test 'should update function_code' do
    patch :update, id: @function_code, function_code: { label: @function_code.label }
    assert_redirected_to function_code_path( assigns( :function_code ))
  end

  test 'should destroy function_code' do
    assert_difference( 'FunctionCode.count', -1) do
      delete :destroy, id: @function_code
    end
    assert_redirected_to function_codes_path
  end
end
