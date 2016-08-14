require 'test_helper'
class A6CodesControllerTest < ActionController::TestCase

  setup do
    @a6_code = a6_codes(:one)
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_A6_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :a6_codes )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create a6_code" do
    assert_difference( 'A6Code.count' ) do
      post :create, a6_code: { active: @a6_code.active, code: @a6_code.code, label: @a6_code.label, mapping: @a6_code.mapping, master: false }
    end
    assert_redirected_to a6_code_path( assigns( :a6_code ))
  end

  test "should show a6_code" do
    get :show, id: @a6_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @a6_code
    assert_response :success
  end

  test "should update a6_code" do
    patch :update, id: @a6_code, a6_code: { active: @a6_code.active, code: @a6_code.code, label: @a6_code.label, mapping: @a6_code.mapping, master: @a6_code.master }
    assert_redirected_to a6_code_path( assigns( :a6_code ))
  end

  test "should destroy a6_code" do
    assert_difference( 'A6Code.count', -1 ) do
      delete :destroy, id: @a6_code
    end
    assert_redirected_to a6_codes_path
  end
end
