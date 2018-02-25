require 'test_helper'
class BaseControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get base_path
    validate_feature_class_attributes FEATURE_ID_BASE_PAGE, 
      ApplicationController::FEATURE_ACCESS_USER +
      ApplicationController::FEATURE_ACCESS_NBP
  end

  test 'should get index' do
    get base_path
    assert_response :success
  end

end
