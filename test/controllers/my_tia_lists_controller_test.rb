require 'test_helper'
class MyTiaListsControllerTest < ActionController::TestCase

  setup do
    @tia_list = tia_lists( :tia_list_one )
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class attributes" do
    validate_feature_class_attributes FEATURE_ID_MY_TIA_LISTS, 
      ApplicationController::FEATURE_ACCESS_SOME,
      ApplicationController::FEATURE_CONTROL_CUG
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :tia_lists )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tia_list" do
    assert_difference( 'TiaList.count' ) do
      post :create, tia_list: { code: @tia_list.code + '+', label: @tia_list.label, owner_account_id: @account.id }
    end
    assert_redirected_to my_tia_list_path( assigns( :tia_list ))
  end

  test "should not create tia_list with same name" do
    assert_no_difference( 'TiaList.count' ) do
      post :create, tia_list: { code: @tia_list.code, label: @tia_list.label, owner_account_id: @account.id }
    end
    assert_response :success
  end

  test "attempt to assign owner nil and deputy nil" do
    assert_no_difference 'TiaList.count' do
      post :create, tia_list: { code: @tia_list.code + '+', label: @tia_list.label, owner_account_id: nil }
    end
    assert_response :success
  end

  test "attempt to assign bad owner and deputy nil" do
    a2 = accounts( :account_two )
    assert_no_difference 'TiaList.count' do
      post :create, tia_list: { code: @tia_list.code + '+', label: @tia_list.label, owner_account_id: a2.id }
    end
    assert_response :success
  end

  test "should show tia_list" do
    get :show, id: @tia_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tia_list
    assert_response :success
  end

  test "should update tia_list" do
    patch :update, id: @tia_list, tia_list: {
      code:               @tia_list.code,
      label:              @tia_list.label,
      deputy_account_id:  @tia_list.deputy_account_id }
    assert_redirected_to my_tia_list_path( assigns( :tia_list ))
  end

  test "should destroy tia_list" do
    assert_difference( 'TiaList.count', -1) do
      delete :destroy, id: @tia_list
    end
    assert_redirected_to my_tia_lists_path
  end


  
end
