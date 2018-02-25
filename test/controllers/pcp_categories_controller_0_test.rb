require 'test_helper'
class PcpCategoriesController0Test < ActionDispatch::IntegrationTest

  setup do
    @pcp_category = pcp_categories( :one )
    signon_by_user accounts( :one )
  end

  test 'check class attributes' do
    get pcp_categories_path
    validate_feature_class_attributes FEATURE_ID_PCP_CATEGORIES, 
      ApplicationController::FEATURE_ACCESS_SOME,
      ApplicationController::FEATURE_CONTROL_GRP
  end

  test 'should get index' do
    get pcp_categories_path
    assert_response :success
    assert_not_nil assigns( :pcp_categories )
  end

  test 'should get new' do
    get new_pcp_category_path
    assert_response :success
  end

  test 'should create pcp_category' do
    assert_difference( 'PcpCategory.count' ) do
      post pcp_categories_path( params:{ pcp_category: { label: @pcp_category.label, description: @pcp_category.description,
        c_group_id: @pcp_category.c_group_id, p_group_id: @pcp_category.p_group_id,
        c_owner_id: @pcp_category.c_owner_id, p_owner_id: @pcp_category.p_owner_id }})
    end
    assert_redirected_to pcp_category_path( assigns( :pcp_category ))
  end

  test 'should show pcp_category' do
    get pcp_category_path( id: @pcp_category )
    assert_response :success
  end

  test 'should get edit' do
    get pcp_category_path( id: @pcp_category )
    assert_response :success
  end

  test 'should update pcp_category' do
    patch pcp_category_path( id: @pcp_category, params:{ pcp_category: { label: @pcp_category.label,
      description: @pcp_category.description,
      c_group_id: @pcp_category.c_group_id, p_group_id: @pcp_category.p_group_id }})
    assert_redirected_to pcp_category_path( assigns( :pcp_category ))
  end

  test 'should destroy pcp_category' do
    assert_difference( 'PcpCategory.count', -1) do
      delete pcp_category_path( id: @pcp_category )
    end
    assert_redirected_to pcp_categories_path
  end
end
