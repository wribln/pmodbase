require 'test_helper'
class SubmissionGroupsControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @sg = submission_groups( :sub_group_one )
  end

  test 'check class_attributes'  do
    get submission_groups_path
    validate_feature_class_attributes FEATURE_ID_SUBMISSION_GROUPS, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get submission_groups_path
    assert_response :success
    assert_not_nil assigns( :submission_groups )
  end

  test 'should get new' do
    get new_submission_group_path
    assert_response :success
  end

  test 'should create submission group' do
    assert_difference( 'SubmissionGroup.count' ) do
      post submission_groups_path, params:{ submission_group: { code: @sg.code << 'a' }}
    end
    assert_redirected_to submission_group_path( assigns( :submission_group ))
  end

  test 'should show submission group' do
    get submission_group_path( id: @sg )
    assert_response :success
  end

  test 'should get edit submission group' do
    get edit_submission_group_path( id: @sg )
    assert_response :success
  end

  test 'should update submission group' do
    patch submission_group_path( id: @sg, params:{ submission_group:{ label: @sg.label }})
    assert_redirected_to submission_group_path( assigns( :submission_group ))
  end

  test 'should destroy submission group' do
    assert_difference('SubmissionGroup.count', -1) do
      delete submission_group_path( id: @sg )
    end
    assert_redirected_to submission_groups_path
  end
end
