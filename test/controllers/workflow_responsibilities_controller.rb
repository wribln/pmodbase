require 'test_helper'
class WorkflowResponsibilitiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
  end

  test 'check class_attributes' do
    get wrq_path
    validate_feature_class_attributes FEATURE_ID_WORKFLOW_PERMISSIONS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get wrq_path
    assert_response :success
    assert_not_nil assigns( :permissions )
  end

end
