
require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase

  setup do
    @p = people(:person_one)
    session[:current_user_id] = accounts(:account_one).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_PROFILE, 
      ApplicationController::FEATURE_ACCESS_USER +
      ApplicationController::FEATURE_ACCESS_NBP
  end

  test "should show profile" do
    get :show
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should update profile/person" do
    patch :update, id: @p, person: { formal_name: @p.formal_name }
    assert_response :success
  end

end
