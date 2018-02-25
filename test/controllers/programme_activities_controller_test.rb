require 'test_helper'
class ProgrammeActivitiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @programme_activity = programme_activities( :ppa_one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get programme_activities_path
    validate_feature_class_attributes FEATURE_ID_ACTIVITIES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get programme_activities_path
    assert_response :success
    assert_not_nil assigns( :programme_activities )
  end

  test 'should get new' do
    get new_programme_activity_path
    assert_response :success
  end

  test 'should create programme_activity' do
    assert_difference( 'ProgrammeActivity.count' ) do
      post programme_activities_path( params:{ programme_activity: {
        project_id: @programme_activity.project_id,
        activity_id: @programme_activity.activity_id + 'a', # must be unique!
        activity_label: @programme_activity.activity_label,
        finish_date: @programme_activity.finish_date,
        start_date: @programme_activity.start_date }})
    end
    assert_redirected_to programme_activity_path(assigns( :programme_activity ))
  end

  test 'should show programme_activity' do
    get programme_activity_path( id: @programme_activity )
    assert_response :success
  end

  test 'should get edit' do
    get programme_activity_path( id: @programme_activity )
    assert_response :success
  end

  test 'should update programme_activity' do
    patch programme_activity_path( id: @programme_activity, params:{ programme_activity: {
      project_id: @programme_activity.project_id,
      activity_id: @programme_activity.activity_id,
      activity_label: @programme_activity.activity_label,
      finish_date: @programme_activity.finish_date,
      start_date: @programme_activity.start_date }})
    assert_redirected_to programme_activity_path(assigns(:programme_activity))
  end

  test 'should destroy programme_activity' do
    assert_difference('ProgrammeActivity.count', -1) do
      delete programme_activity_path( id: @programme_activity )
    end

    assert_redirected_to programme_activities_path
  end
end
