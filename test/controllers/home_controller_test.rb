require 'test_helper'
class HomeControllerTest < ActionDispatch::IntegrationTest

  test 'check class_attributes' do
    get home_path
    validate_feature_class_attributes FEATURE_ID_HOME_PAGE, 
      ApplicationController::FEATURE_ACCESS_ALL + 
      ApplicationController::FEATURE_ACCESS_NBP
  end

  test 'should get index' do
    get home_path
    assert_response :success
  end

end
