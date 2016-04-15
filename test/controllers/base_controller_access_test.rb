require 'test_helper'
class BaseControllerAccessTest < ActionController::TestCase
  tests BaseController

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_BASE_PAGE, ApplicationController::FEATURE_ACCESS_USER
  end

 test "index is permitted with specific entries" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    get :index
    assert_response :success
    assert_select 'title', 'TEST: Base Page'
    assert_select 'h1', { text: 'Welcome to the pmodbase test system!', count: 1 }
  end

  test "should not get index" do
    @account = nil
    session[ :current_user_id ] = nil
    get :index
    assert_response :unauthorized
  end

end
