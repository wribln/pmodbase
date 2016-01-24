require 'test_helper'
class FeaturesControllerTest < ActionController::TestCase

  setup do
    @feature = features( :feature_1 )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_FEATURE_ITEMS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test "ensure consistency of test data" do
    assert_not_nil @feature.feature_category_id
    assert_not_nil @feature.code
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :features )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feature" do
    assert_difference( 'Feature.count' ) do
      post :create, feature: { 
        code: @feature.code + "99",
        label: @feature.label,
        seqno: @feature.seqno, 
        feature_category_id: @feature.feature_category_id }
    end
    assert_redirected_to feature_path( assigns( :feature ))
  end

  test "should show feature" do
    get :show, id: @feature
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @feature
    assert_response :success
  end

  test "should update feature" do
    patch :update, id: @feature, feature: { code: @feature.code, label: @feature.label, seqno: @feature.seqno }
    assert_redirected_to feature_path( assigns( :feature ))
  end

  test "should destroy feature" do
    assert_difference('Feature.count', -1) do
      delete :destroy, id: @feature
    end

    assert_redirected_to features_path
  end
end
