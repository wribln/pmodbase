require 'test_helper'
class WorkflowResponsibilitiesControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class_attributes" do
    validate_feature_class_attributes FEATURE_ID_WORKFLOW_PERMISSIONS,
      ApplicationController::FEATURE_ACCESS_SOME
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :permissions )
  end

end
