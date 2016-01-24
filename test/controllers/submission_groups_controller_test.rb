require 'test_helper'
class SubmissionGroupsControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
    @sg = submission_groups( :sub_group_one )
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_SUBMISSION_GROUPS, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :submission_groups )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create submission group" do
    assert_difference( 'SubmissionGroup.count' ) do
      post :create, submission_group: { code: @sg.code << 'a' }
    end
    assert_redirected_to submission_group_path( assigns( :submission_group ))
  end

  test "should show submission group" do
    get :show, id: @sg
    assert_response :success
  end

  test "should get edit submission group" do
    get :edit, id: @sg
    assert_response :success
  end

  test "should update submission group" do
    patch :update, id: @sg, submission_group: {
      label:      @sg.label }
    assert_redirected_to submission_group_path( assigns( :submission_group ))
  end

  test "should destroy submission group" do
    assert_difference('SubmissionGroup.count', -1) do
      delete :destroy, id: @sg
    end

    assert_redirected_to submission_groups_path
  end
end
