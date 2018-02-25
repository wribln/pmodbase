require 'test_helper'
class GroupCategoriesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @group_category = group_categories( :group_category_one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get group_categories_path
    validate_feature_class_attributes FEATURE_ID_GROUP_CATEGORIES, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'check fixture' do
    assert_not @group_category.label.empty?
    assert @group_category.seqno > 0
  end

  test 'should get index' do
    get group_categories_path
    assert_response :success
    assert_not_nil assigns( :group_categories )
  end

  test 'should get new' do
    get new_group_category_path
    assert_response :success
  end

  test 'should create group_category' do
    assert_difference( 'GroupCategory.count' ) do
      post group_categories_path( params:{ group_category: { label: @group_category.label, seqno: @group_category.seqno }})
    end
    assert_redirected_to group_category_path(assigns(:group_category))
  end

  test 'should show group_category' do
    get group_category_path( id: @group_category )
    assert_response :success
  end

  test 'should get edit' do
    get edit_group_category_path( id: @group_category )
    assert_response :success
  end

  test 'should update group_category' do
    patch group_category_path( id: @group_category, params:{ group_category: { label: @group_category.label, seqno: @group_category.seqno }})
    assert_redirected_to group_category_path(assigns(:group_category))
  end

  test 'should destroy group_category' do
    # dependent groups cannot be easily destroyed, hence a simple test case with a new group category
    g = GroupCategory.new( label: 'Test' )
    g.save
    assert_difference('GroupCategory.count', -1) do
      delete group_category_path( id: g )
    end
    assert_redirected_to group_categories_path
  end
end
