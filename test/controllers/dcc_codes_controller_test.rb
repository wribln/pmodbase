require 'test_helper'
class DccCodesControllerTest < ActionController::TestCase

  setup do
    @dcc_code = dcc_codes( :one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :dcc_codes )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create dcc_code' do
    assert_difference( 'DccCode.count' ) do
      post :create, dcc_code: { code: @dcc_code.code, label: @dcc_code.label, master: false }
    end
    assert_redirected_to dcc_code_path( assigns( :dcc_code ))
  end

  test 'should show dcc_code' do
    get :show, id: @dcc_code
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @dcc_code
    assert_response :success
  end

  test 'should update dcc_code' do
    patch :update, id: @dcc_code, dcc_code: { label: @dcc_code.label }
    assert_redirected_to dcc_code_path( assigns( :dcc_code ))
  end

  test 'should destroy dcc_code' do
    assert_difference( 'DccCode.count', -1) do
      delete :destroy, id: @dcc_code
    end
    assert_redirected_to dcc_codes_path
  end
end
