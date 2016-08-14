require 'test_helper'
class StatisticsControllerTest < ActionController::TestCase

  setup do
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_DBSTATS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
