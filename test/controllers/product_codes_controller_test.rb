require 'test_helper'
class ProductCodesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @product_code = product_codes( :one )
    signon_by_user accounts( :one )
  end

  test 'should get index' do
    get product_codes_path
    assert_response :success
    assert_not_nil assigns( :product_codes )
  end

  test 'should get new' do
    get new_product_code_path
    assert_response :success
  end

  test 'should create product_code' do
    assert_difference( 'ProductCode.count' ) do
      post product_codes_path( params:{ product_code: { code: @product_code.code, label: @product_code.label, master: false }})
    end
    assert_redirected_to product_code_path( assigns( :product_code ))
  end

  test 'should show product_code' do
    get product_code_path( id: @product_code )
    assert_response :success
  end

  test 'should get edit' do
    get edit_product_code_path( id: @product_code )
    assert_response :success
  end

  test 'should update product_code' do
    patch product_code_path( id: @product_code, params:{ product_code: { label: @product_code.label }})
    assert_redirected_to product_code_path( assigns( :product_code ))
  end

  test 'should destroy product_code' do
    assert_difference( 'ProductCode.count', -1) do
      delete product_code_path( id: @product_code )
    end
    assert_redirected_to product_codes_path
  end
end
