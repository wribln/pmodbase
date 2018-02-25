require 'test_helper'
class AbbrSearchControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get sfa_path
    validate_feature_class_attributes FEATURE_ID_ABBR_SEARCH, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test 'should get index' do
    get sfa_path
    assert_response :success
  end

end
