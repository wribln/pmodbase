require 'test_helper'
class BaseControllerAccessTest < ActionDispatch::IntegrationTest

  test 'check class_attributes'  do
    signon_by_user accounts( :wop )
    get base_path
    validate_feature_class_attributes FEATURE_ID_BASE_PAGE, 
      ApplicationController::FEATURE_ACCESS_USER +
      ApplicationController::FEATURE_ACCESS_NBP
  end

 test 'index is permitted with specific entries' do
    signon_by_user accounts( :wop )
    get base_path
    assert_response :success
    assert_select 'title', 'TEST: Base Page'
    assert_select 'h1', { text: 'Welcome to the pmodbase test system!', count: 1 }
  end

  test 'should not get index' do
    get base_path
    assert_response :unauthorized
  end

end
