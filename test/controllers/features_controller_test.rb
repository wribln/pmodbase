require 'test_helper'
class FeaturesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @feature = features( :feature_1 )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get features_path
    validate_feature_class_attributes FEATURE_ID_FEATURE_ITEMS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'ensure consistency of test data' do
    assert_not_nil @feature.feature_category_id
    assert_not_nil @feature.code
  end

  test 'should get index' do
    get features_path
    assert_response :success
    assert_not_nil assigns( :features )
  end

  test 'should get new' do
    get new_feature_path
    assert_response :success
  end

  test 'should create feature' do
    assert_difference( 'Feature.count' ) do
      post features_path( params:{ feature: { 
        code: @feature.code + '99',
        label: @feature.label,
        seqno: @feature.seqno, 
        feature_category_id: @feature.feature_category_id }})
    end
    assert_redirected_to feature_path( assigns( :feature ))
  end

  test 'should show feature' do
    get feature_path( id: @feature )
    assert_response :success
  end

  test 'should get edit' do
    get edit_feature_path( id: @feature )
    assert_response :success
  end

  test 'should update feature' do
    patch feature_path( id: @feature, params:{ feature: { code: @feature.code, label: @feature.label, seqno: @feature.seqno }})
    assert_redirected_to feature_path( assigns( :feature ))
  end

  test 'should destroy feature' do
    assert_difference('Feature.count', -1) do
      delete feature_path( id: @feature )
    end
    assert_redirected_to features_path
  end
end
