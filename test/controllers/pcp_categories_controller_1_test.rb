require 'test_helper'
class PcpCategoriesController1Test < ActionController::TestCase
  tests PcpCategoriesController

  # USER HAS NO PERMISSIONS - may view information only

  setup do
    @pcp_category = pcp_categories(:one)
    session[ :current_user_id ] = accounts( :wop ).id
  end

  test 'should get index' do
    get :index
    check_for_cr
  end

  test 'should get new' do
    get :new
    check_for_cr
  end

  test 'should create pcp_category' do
    assert_difference( 'PcpCategory.count', 0 ) do
      post :create, pcp_category: { label: @pcp_category.label,
        c_group_id: @pcp_category.c_group_id, p_group_id: @pcp_category.p_group_id,
        c_owner_id: @pcp_category.c_owner_id, p_owner_id: @pcp_category.p_owner_id }
    end
    check_for_cr
  end

  test 'should show pcp_category' do
    get :show, id: @pcp_category
    check_for_cr
  end

  test 'should get edit' do
    get :edit, id: @pcp_category
    check_for_cr
  end

  test 'should update pcp_category' do
    patch :update, id: @pcp_category, pcp_category: { label: @pcp_category.label,
      c_group_id: @pcp_category.c_group_id, p_group_id: @pcp_category.p_group_id }
    check_for_cr
  end

  test 'should destroy pcp_category' do
    assert_difference( 'PcpCategory.count', 0 ) do
      delete :destroy, id: @pcp_category
    end
    check_for_cr
  end

end
