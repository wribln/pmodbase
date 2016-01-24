require 'test_helper'
class MyChangeRequestsControllerTest < ActionController::TestCase
  
  setup do
    @dbcr1 = db_change_requests( :dbcr_one )
    session[:current_user_id] = accounts( :account_one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_MY_CHANGE_REQUESTS, ApplicationController::FEATURE_ACCESS_USER
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :dbcrs )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create db_change_request" do
    assert_difference( 'DbChangeRequest.count' ) do
      post :create, db_change_request: { 
          requesting_account_id: accounts( :account_one ).id,
          action: @dbcr1.action,
          feature_id: @dbcr1.feature_id,
          detail: @dbcr1.detail,
          request_text: @dbcr1.request_text }
    end

    assert_redirected_to my_change_request_path( assigns( :dbcr ))
  end

  test "should show db_change_request" do
    get :show, id: db_change_requests( :dbcr_one ).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: db_change_requests( :dbcr_one ).id
    assert_response :success
  end

  test "should update db_change_request" do
    patch :update, id: @dbcr1, db_change_request: {
          requesting_account_id: accounts(:account_one).id,
          action: @dbcr1.action,
          feature_id: @dbcr1.feature_id,
          detail: @dbcr1.detail,
          request_text: @dbcr1.request_text }
    assert_redirected_to my_change_request_path( assigns( :dbcr ))
  end

  test "should destroy db_change_request" do
    assert_difference( 'DbChangeRequest.count', -1) do
      delete :destroy, id: @dbcr1
    end

    assert_redirected_to my_change_requests_path
  end
end
