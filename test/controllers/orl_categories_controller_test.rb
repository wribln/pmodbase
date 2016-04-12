require 'test_helper'
class OrlCategoriesControllerTest < ActionController::TestCase

  setup do
    @orl_category = orl_categories(:one)
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:orl_categories)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create orl_category' do
    assert_difference('OrlCategory.count') do
      post :create, orl_category: { label: @orl_category.label,
        o_group_id: @orl_category.o_group_id, r_group_id: @orl_category.r_group_id,
        o_owner_id: @orl_category.o_owner_id, r_owner_id: @orl_category.r_owner_id }
    end
    assert_redirected_to orl_category_path( assigns( :orl_category ))
  end

  test 'should show orl_category' do
    get :show, id: @orl_category
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @orl_category
    assert_response :success
  end

  test 'should update orl_category' do
    patch :update, id: @orl_category, orl_category: { label: @orl_category.label, o_group_id: @orl_category.o_group_id, r_group_id: @orl_category.r_group_id }
    assert_redirected_to orl_category_path( assigns( :orl_category ))
  end

  test 'should destroy orl_category' do
    assert_difference( 'OrlCategory.count', -1) do
      delete :destroy, id: @orl_category
    end

    assert_redirected_to orl_categories_path
  end
end
