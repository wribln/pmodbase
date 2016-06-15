require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_HOME_PAGE, 
      ApplicationController::FEATURE_ACCESS_ALL + 
      ApplicationController::FEATURE_ACCESS_NBP
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
