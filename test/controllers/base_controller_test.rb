require 'test_helper'
class BaseControllerTest < ActionController::TestCase

  setup do
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_BASE_PAGE, 
      ApplicationController::FEATURE_ACCESS_USER +
      ApplicationController::FEATURE_ACCESS_NBP
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
