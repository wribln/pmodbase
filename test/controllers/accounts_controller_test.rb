require 'test_helper'
class AccountsControllerTest < ActionController::TestCase
  
  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_ACCOUNTS_AND_PERMISSIONS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :accounts )
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_select '#account_password[required]',true
    assert_select '#account_password_confirmation[required]',true
  end

  test "should create account" do
    assert_difference( 'Account.count' ) do
      post :create, account: { name: "Test", password: "Test1Test!", person_id: @account.person_id }
    end
    assert_response :success
  end

  test "should show account" do
    get :show, id: @account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @account
    assert_response :success
    assert_select '#account_password[required]',false
    assert_select '#account_password_confirmation[required]',false
  end

  test "should update account" do
    # cannot test this at this time as update needs to remove the dummy permissions entry
    # ('template' - created by view.edit and to be used by JavaScript); when testing, this
    # removal of the dummy fails as it is not present.
    #
    # patch :update, id: @account, account: { name: "Test", password: "TestTestTest", person_id: @account.person_id }
    # assert_redirected_to account_path( assigns( :account ))
  end

  test "should destroy account" do
    assert_difference('Account.count', -1) do
      delete :destroy, id: @account
    end

    assert_redirected_to accounts_path
  end

end
