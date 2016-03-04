require 'test_helper'
class ProgrammeActivitiesControllerTest < ActionController::TestCase

  setup do
    @programme_activity = programme_activities( :ppa_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_ACTIVITIES, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :programme_activities )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create programme_activity" do
    assert_difference('ProgrammeActivity.count') do
      post :create, programme_activity: {
        project_id: @programme_activity.project_id,
        activity_id: @programme_activity.activity_id + 'a', # must be unique!
        activity_label: @programme_activity.activity_label,
        finish_date: @programme_activity.finish_date,
        start_date: @programme_activity.start_date }
    end
    assert_redirected_to programme_activity_path(assigns( :programme_activity ))
  end

  test "should show programme_activity" do
    get :show, id: @programme_activity
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @programme_activity
    assert_response :success
  end

  test "should update programme_activity" do
    patch :update, id: @programme_activity, programme_activity: {
      project_id: @programme_activity.project_id,
      activity_id: @programme_activity.activity_id,
      activity_label: @programme_activity.activity_label,
      finish_date: @programme_activity.finish_date,
      start_date: @programme_activity.start_date }
    assert_redirected_to programme_activity_path(assigns(:programme_activity))
  end

  test "should destroy programme_activity" do
    assert_difference('ProgrammeActivity.count', -1) do
      delete :destroy, id: @programme_activity
    end

    assert_redirected_to programme_activities_path
  end
end
