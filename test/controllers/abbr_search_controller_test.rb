require 'test_helper'
class AbbrSearchControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_ABBR_SEARCH, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
