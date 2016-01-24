require 'test_helper'
class DsrSubmissionsControllerTest < ActionController::TestCase

#  setup do
#    @dsr_submission = dsr_submissions(:one)
#  end
#
  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_DSR_SUBMISSIONS, ApplicationController::FEATURE_ACCESS_SOME
  end

#  test "should get index" do
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:dsr_submissions)
#  end
#
#  test "should get new" do
#    get :new
#    assert_response :success
#  end
#
#  test "should create dsr_submission" do
#    assert_difference('DsrSubmission.count') do
#      post :create, dsr_submission: { plan_sub_date: @dsr_submission.plan_sub_date }
#    end
#
#    assert_redirected_to dsr_submission_path(assigns(:dsr_submission))
#  end
#
#  test "should show dsr_submission" do
#    get :show, id: @dsr_submission
#    assert_response :success
#  end
#
#  test "should get edit" do
#    get :edit, id: @dsr_submission
#    assert_response :success
#  end
#
#  test "should update dsr_submission" do
#    patch :update, id: @dsr_submission, dsr_submission: { plan_sub_date: @dsr_submission.plan_sub_date }
#    assert_redirected_to dsr_submission_path(assigns(:dsr_submission))
#  end
#
#  test "should destroy dsr_submission" do
#    assert_difference('DsrSubmission.count', -1) do
#      delete :destroy, id: @dsr_submission
#    end
#
#    assert_redirected_to dsr_submissions_path
#  end
end
