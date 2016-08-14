require 'test_helper'
class GroupCategoriesControllerTest < ActionController::TestCase

  setup do
    @group_category = group_categories( :group_category_one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_GROUP_CATEGORIES, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'check fixture' do
    assert_not @group_category.label.empty?
    assert @group_category.seqno > 0
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :group_categories )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create group_category' do
    assert_difference( 'GroupCategory.count' ) do
      post :create, group_category: { label: @group_category.label, seqno: @group_category.seqno }
    end

    assert_redirected_to group_category_path(assigns(:group_category))
  end

  test 'should show group_category' do
    get :show, id: @group_category
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @group_category
    assert_response :success
  end

  test 'should update group_category' do
    patch :update, id: @group_category, group_category: { label: @group_category.label, seqno: @group_category.seqno }
    assert_redirected_to group_category_path(assigns(:group_category))
  end

  test 'should destroy group_category' do
    # dependent groups cannot be easily destroyed, hence a simple test case with a new group category
    g = GroupCategory.new( label: 'Test' )
    g.save
    assert_difference('GroupCategory.count', -1) do
      delete :destroy, id: g
    end

    assert_redirected_to group_categories_path
  end
end
