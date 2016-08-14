require 'test_helper'
class A4CodesControllerTest < ActionController::TestCase

  setup do
    @a4_code = a4_codes(:one)
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_A4_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :a4_codes )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create a4_code" do
    assert_difference( 'A4Code.count' ) do
      post :create, a4_code: { active: @a4_code.active, code: @a4_code.code, label: @a4_code.label, mapping: @a4_code.mapping, master: false }
    end
    assert_redirected_to a4_code_path( assigns( :a4_code ))
  end

  test "should show a4_code" do
    get :show, id: @a4_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @a4_code
    assert_response :success
  end

  test "should update a4_code" do
    patch :update, id: @a4_code, a4_code: { active: @a4_code.active, code: @a4_code.code, label: @a4_code.label, mapping: @a4_code.mapping, master: @a4_code.master }
    assert_redirected_to a4_code_path( assigns( :a4_code ))
  end

  test "should destroy a4_code" do
    assert_difference( 'A4Code.count', -1 ) do
      delete :destroy, id: @a4_code
    end
    assert_redirected_to a4_codes_path
  end
end
