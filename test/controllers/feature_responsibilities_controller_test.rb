require 'test_helper'
class FeatureResponsibilitiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get frq_path
    validate_feature_class_attributes FEATURE_ID_FEATURE_RESP, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get frq_path
    assert_response :success
  end

end
