require 'test_helper'
class DsrSubmissionsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @dsr_submission = dsr_submissions( :dsr_sub_one )
    @dsr_record = dsr_status_records( :dsr_rec_one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get dsr_submissions_path
    validate_feature_class_attributes FEATURE_ID_DSR_SUBMISSIONS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get dsr_submissions_path
    assert_response :success
    assert_not_nil assigns( :dsr_submissions )
  end

  test 'should get new' do
    get new_dsr_submission_path
    assert_response :success
  end

  test 'should create dsr_submission' do
    assert_difference( 'DsrSubmission.count' ) do
      post dsr_submissions_path( params:{ dsr_submission: { dsr_status_record_id: @dsr_record.id, plnd_submission: @dsr_submission.plnd_submission }})
      ds = assigns( :dsr_submission )
      assert_empty ds.errors, ds.errors.full_messages
    end
    assert_redirected_to dsr_submission_path(assigns(:dsr_submission))
  end

  test 'should show dsr_submission' do
    get dsr_submission_path( id: @dsr_submission )
    assert_response :success
  end

  test 'should get edit' do
    get edit_dsr_submission_path( id: @dsr_submission )
    assert_response :success
  end

  test 'should update dsr_submission' do
    patch dsr_submission_path( id: @dsr_submission, params:{ dsr_submission: { plnd_submission: @dsr_submission.plnd_submission }})
    assert_redirected_to dsr_submission_path(assigns(:dsr_submission))
  end

  test 'should destroy dsr_submission' do
    assert_difference('DsrSubmission.count', -1) do
      delete dsr_submission_path( id: @dsr_submission )
    end
    assert_redirected_to dsr_submissions_path
  end

end
