require 'test_helper'
class A8CodesControllerTest < ActionController::TestCase

  setup do
    @a8_code = a8_codes(:one)
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_A8_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :a8_codes )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create a8_code" do
    assert_difference( 'A8Code.count' ) do
      post :create, a8_code: { active: @a8_code.active, code: @a8_code.code, label: @a8_code.label, mapping: @a8_code.mapping, master: false }
    end
    assert_redirected_to a8_code_path( assigns( :a8_code ))
  end

  test "should show a8_code" do
    get :show, id: @a8_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @a8_code
    assert_response :success
  end

  test "should update a8_code" do
    patch :update, id: @a8_code, a8_code: { active: @a8_code.active, code: @a8_code.code, label: @a8_code.label, mapping: @a8_code.mapping, master: @a8_code.master }
    assert_redirected_to a8_code_path( assigns( :a8_code ))
  end

  test "should destroy a8_code" do
    assert_difference( 'A8Code.count', -1 ) do
      delete :destroy, id: @a8_code
    end
    assert_redirected_to a8_codes_path
  end
end
