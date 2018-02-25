require 'test_helper'
class ProfilesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @p = people( :person_one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get profile_path
    validate_feature_class_attributes FEATURE_ID_PROFILE, ApplicationController::FEATURE_ACCESS_USER + ApplicationController::FEATURE_ACCESS_NBP
  end

  test 'should show profile' do
    get profile_path
    assert_response :success
  end

  test 'should get edit' do
    get edit_profile_path
    assert_response :success
  end

  test 'should update profile/person' do
    patch profile_path( id: @p, params:{ person: { formal_name: @p.formal_name }})
    assert_response :success
  end

end
