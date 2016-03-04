require 'test_helper'
class ProductCodesControllerTest < ActionController::TestCase

  setup do
    @product_code = product_codes( :one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :product_codes )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create product_code' do
    assert_difference( 'ProductCode.count' ) do
      post :create, product_code: { code: @product_code.code, label: @product_code.label, master: false }
    end
    assert_redirected_to product_code_path( assigns( :product_code ))
  end

  test 'should show product_code' do
    get :show, id: @product_code
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @product_code
    assert_response :success
  end

  test 'should update product_code' do
    patch :update, id: @product_code, product_code: { label: @product_code.label }
    assert_redirected_to product_code_path( assigns( :product_code ))
  end

  test 'should destroy product_code' do
    assert_difference( 'ProductCode.count', -1) do
      delete :destroy, id: @product_code
    end
    assert_redirected_to product_codes_path
  end
end
