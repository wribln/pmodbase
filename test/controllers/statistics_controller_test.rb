require 'test_helper'
class StatisticsControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get statistics_path
    validate_feature_class_attributes FEATURE_ID_DBSTATS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get statistics_path
    assert_response :success
  end

end
