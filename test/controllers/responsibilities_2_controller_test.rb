require 'test_helper'
class ResponsibilitiesController2Test < ActionController::TestCase
  tests ResponsibilitiesController

  # test with no permissions

  setup do
    @responsibility = responsibilities( :one )
    @a = accounts( :wop )
    session[ :current_user_id ] = @a.id
    @request.env["HTTP_REFERER"] = 'http://test.host/index'
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_RESPONSIBILITIES,
      ApplicationController::FEATURE_ACCESS_SOME,
      ApplicationController::FEATURE_CONTROL_GRP, 0
  end

  test "ensure correct setup" do
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_create ), "no permission to create"
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_read ), "no permission to read"
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_update ), "no permission to update"
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_delete ), "no permission to delete"
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_index ), "no permission to index"
  end

  test "should get index" do
    get :index
    assert_nil assigns( :responsibilities )
    check_for_cr
  end

  test "should get new" do
    get :new
    check_for_cr
  end

  test "should create responsibility" do
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_create, @responsibility.group_id ), 'no permission!'
    assert_difference( 'Responsibility.count', 0 ) do
      post :create, responsibility: { group_id: @responsibility.group_id, 
        person_id: @responsibility.person_id,
        description: @responsibility.description, seqno: @responsibility.seqno }
    end
    check_for_cr
  end

  test "should show responsibility" do
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_read, @responsibility.group_id ), 'no permission!'
    get :show, id: @responsibility
    check_for_cr
  end

  test "should get edit" do
    get :edit, id: @responsibility
    check_for_cr
  end

  test "should update responsibility" do
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_update, @responsibility.group_id ), 'no permission!'
    patch :update, id: @responsibility, responsibility: { description: @responsibility.description, seqno: @responsibility.seqno }
    check_for_cr
  end

  test "should destroy responsibility" do
    assert_equal false, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_delete, @responsibility.group_id ), 'no permission!'
    assert_difference( 'Responsibility.count', 0 ) do
      delete :destroy, id: @responsibility
    end
    check_for_cr
  end
end
