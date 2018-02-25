require 'test_helper'
class FeatureCategoriesControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    @feature_category = feature_categories( :feature_category_one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get feature_categories_path
    validate_feature_class_attributes FEATURE_ID_FEATURE_CATEGORIES, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get feature_categories_path
    assert_response :success
    assert_not_nil assigns( :feature_categories )
  end

  test 'should get new' do
    get new_feature_category_path
    assert_response :success
  end

  test 'should create feature category' do
    assert_difference('FeatureCategory.count') do
      post feature_categories_path( params:{ feature_category: { label: @feature_category.label, seqno: 1 }})
    end
    assert_redirected_to feature_category_path(assigns( :feature_category ))
  end

  test 'should show feature_category' do
    get feature_category_path( id: @feature_category )
    assert_response :success
  end

  test 'should get edit' do
    get edit_feature_category_path( id: @feature_category )
    assert_response :success
  end

  test 'should update feature_category' do
    patch feature_category_path( id: @feature_category, params:{ feature_category: {  label: @feature_category.label, seqno: 1 }})
    assert_redirected_to feature_category_path( assigns( :feature_category ))
  end

  test 'should destroy feature_category' do
    assert_difference('FeatureCategory.count', -1) do
      delete feature_category_path( id: @feature_category )
    end
    assert_redirected_to feature_categories_path
  end
end
