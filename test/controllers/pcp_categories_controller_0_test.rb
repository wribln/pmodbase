require 'test_helper'
class PcpCategoriesController0Test < ActionController::TestCase
  tests PcpCategoriesController

  setup do
    @pcp_category = pcp_categories(:one)
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test 'check class attributes' do
    validate_feature_class_attributes FEATURE_ID_PCP_CATEGORIES, 
      ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :pcp_categories )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create pcp_category' do
    assert_difference( 'PcpCategory.count' ) do
      post :create, pcp_category: { label: @pcp_category.label,
        c_group_id: @pcp_category.c_group_id, p_group_id: @pcp_category.p_group_id,
        c_owner_id: @pcp_category.c_owner_id, p_owner_id: @pcp_category.p_owner_id }
    end
    assert_redirected_to pcp_category_path( assigns( :pcp_category ))
  end

  test 'should show pcp_category' do
    get :show, id: @pcp_category
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @pcp_category
    assert_response :success
  end

  test 'should update pcp_category' do
    patch :update, id: @pcp_category, pcp_category: { label: @pcp_category.label,
      c_group_id: @pcp_category.c_group_id, p_group_id: @pcp_category.p_group_id }
    assert_redirected_to pcp_category_path( assigns( :pcp_category ))
  end

  test 'should destroy pcp_category' do
    assert_difference( 'PcpCategory.count', -1) do
      delete :destroy, id: @pcp_category
    end
    assert_redirected_to pcp_categories_path
  end
end
