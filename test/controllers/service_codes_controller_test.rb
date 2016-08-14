require 'test_helper'
class ServiceCodesControllerTest < ActionController::TestCase

  setup do
    @service_code = service_codes( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :service_codes )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create service_code' do
    assert_difference( 'ServiceCode.count' ) do
      post :create, service_code: { code: @service_code.code, label: @service_code.label, master: false }
    end
    assert_redirected_to service_code_path( assigns( :service_code ))
  end

  test 'should show service_code' do
    get :show, id: @service_code
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @service_code
    assert_response :success
  end

  test 'should update service_code' do
    patch :update, id: @service_code, service_code: { label: @service_code.label }
    assert_redirected_to service_code_path( assigns( :service_code ))
  end

  test 'should destroy service_code' do
    assert_difference( 'ServiceCode.count', -1) do
      delete :destroy, id: @service_code
    end
    assert_redirected_to service_codes_path
  end
end
