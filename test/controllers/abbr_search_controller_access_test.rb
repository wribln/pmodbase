require 'test_helper'
class AbbrSearchControllerAccessTest < ActionController::TestCase
  tests AbbrSearchController

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_ABBR_SEARCH, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "should get index" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    get :index
    assert_response :success
  end

  test "should not get index" do
    @account = nil
    session[ :current_user_id ] = nil
    get :index
    assert_response :unauthorized
  end

end
