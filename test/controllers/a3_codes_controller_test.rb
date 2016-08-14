require 'test_helper'
class A3CodesControllerTest < ActionController::TestCase

  setup do
    @a3_code = a3_codes(:one)
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_A3_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :a3_codes )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create a3_code" do
    assert_difference( 'A3Code.count' ) do
      post :create, a3_code: { active: @a3_code.active, code: @a3_code.code, label: @a3_code.label, mapping: @a3_code.mapping, master: false }
    end
    assert_redirected_to a3_code_path( assigns( :a3_code ))
  end

  test "should show a3_code" do
    get :show, id: @a3_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @a3_code
    assert_response :success
  end

  test "should update a3_code" do
    patch :update, id: @a3_code, a3_code: { active: @a3_code.active, code: @a3_code.code, label: @a3_code.label, mapping: @a3_code.mapping, master: @a3_code.master }
    assert_redirected_to a3_code_path( assigns( :a3_code ))
  end

  test "should destroy a3_code" do
    assert_difference( 'A3Code.count', -1 ) do
      delete :destroy, id: @a3_code
    end
    assert_redirected_to a3_codes_path
  end
end
