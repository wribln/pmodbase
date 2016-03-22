require 'test_helper'
class A5CodesControllerTest < ActionController::TestCase

  setup do
    @a5_code = a5_codes(:one)
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_A5_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :a5_codes )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create a5_code" do
    assert_difference( 'A5Code.count' ) do
      post :create, a5_code: { active: @a5_code.active, code: @a5_code.code, label: @a5_code.label, mapping: @a5_code.mapping, master: false }
    end
    assert_redirected_to a5_code_path( assigns( :a5_code ))
  end

  test "should show a5_code" do
    get :show, id: @a5_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @a5_code
    assert_response :success
  end

  test "should update a5_code" do
    patch :update, id: @a5_code, a5_code: { active: @a5_code.active, code: @a5_code.code, label: @a5_code.label, mapping: @a5_code.mapping, master: @a5_code.master }
    assert_redirected_to a5_code_path( assigns( :a5_code ))
  end

  test "should destroy a5_code" do
    assert_difference( 'A5Code.count', -1 ) do
      delete :destroy, id: @a5_code
    end
    assert_redirected_to a5_codes_path
  end
end
