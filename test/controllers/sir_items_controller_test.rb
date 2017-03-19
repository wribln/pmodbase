require 'test_helper'
class SirItemsControllerTest < ActionController::TestCase

  setup do
    @sir_item = sir_items( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'should get index' do
    get :index, sir_log_id: @sir_item.sir_log
    assert_response :success
    assert_not_nil assigns( :sir_items )
  end

  test 'should get statistics' do
    get :show_stats, sir_log_id: @sir_item.sir_log_id
    assert_response :success
    assert_not_nil assigns( :sir_log )
    assert_not_nil assigns( :grand_total )
    assert_not_nil assigns( :stats_by_group )
    assert_not_nil assigns( :stats_by_last )
  end

  test 'should get new' do
    get :new, sir_log_id: @sir_item.sir_log
    assert_response :success
  end

  test 'should create sir_item' do
    assert_difference( 'SirItem.count' ) do
      post :create, sir_log_id: @sir_item.sir_log, 
        sir_item: { description: @sir_item.description,
                    group_id: @sir_item.group_id,
                    label: @sir_item.label,
                    code: 'XX' }
    end
    assert_redirected_to sir_item_path( assigns( :sir_item ))
  end

  test 'should show sir_item' do
    get :show, id: @sir_item
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @sir_item
    assert_response :success
  end

  test 'should update sir_item' do
    patch :update, id: @sir_item, sir_item: { category: @sir_item.category }
    assert_redirected_to sir_item_path( assigns( :sir_item ))
  end

  test 'should destroy sir_item' do
    sir_log = @sir_item.sir_log
    assert_difference( 'SirItem.count', -1 ) do
      delete :destroy, id: @sir_item
    end
    assert_redirected_to sir_log_sir_items_path( sir_log )
  end
end
