require 'test_helper'
class A7CodesControllerTest < ActionController::TestCase

  setup do
    @a7_code = a7_codes(:one)
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_A7_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :a7_codes )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create a7_code" do
    assert_difference( 'A7Code.count' ) do
      post :create, a7_code: { active: @a7_code.active, code: @a7_code.code, label: @a7_code.label, mapping: @a7_code.mapping, master: false }
    end
    assert_redirected_to a7_code_path( assigns( :a7_code ))
  end

  test "should show a7_code" do
    get :show, id: @a7_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @a7_code
    assert_response :success
  end

  test "should update a7_code" do
    patch :update, id: @a7_code, a7_code: { active: @a7_code.active, code: @a7_code.code, label: @a7_code.label, mapping: @a7_code.mapping, master: @a7_code.master }
    assert_redirected_to a7_code_path( assigns( :a7_code ))
  end

  test "should destroy a7_code" do
    assert_difference( 'A7Code.count', -1 ) do
      delete :destroy, id: @a7_code
    end
    assert_redirected_to a7_codes_path
  end
end
