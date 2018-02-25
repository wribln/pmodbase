require 'test_helper'
class SirItemsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @sir_item = sir_items( :one )
    signon_by_user accounts( :one )
  end

  test 'should get index' do
    get sir_log_sir_items_path( sir_log_id: @sir_item.sir_log )
    assert_response :success
    assert_not_nil assigns( :sir_items )
  end

  test 'should get statistics' do
    get sir_item_stats_path( sir_log_id: @sir_item.sir_log_id )
    assert_response :success
    assert_not_nil assigns( :sir_log )
    assert_not_nil gt = assigns( :grand_total )
    assert_not_nil sg = assigns( :stats_by_group )
    assert_not_nil sl = assigns( :stats_by_last )
    assert_equal 2, gt
    assert_equal sg[ 'ONE' ], [0,1,0,0]
    assert_equal sg[ 'TWO' ], [1,0,0,0]
    assert_equal sl[ 'TWO' ], 2
  end

  test 'should get new' do
    get new_sir_log_sir_item_path( sir_log_id: @sir_item.sir_log )
    assert_response :success
  end

  test 'should create sir_item' do
    assert_difference( 'SirItem.count' ) do
      post sir_log_sir_items_path( sir_log_id: @sir_item.sir_log, params:{ 
        sir_item: {
          description: @sir_item.description,
          group_id: @sir_item.group_id,
          label: @sir_item.label,
          code: 'XX' }
        })
    end
    assert_redirected_to sir_item_path( assigns( :sir_item ))
  end

  test 'should show sir_item' do
    get sir_item_path( id: @sir_item )
    assert_response :success
  end

  test 'should get edit' do
    get edit_sir_item_path( id: @sir_item )
    assert_response :success
  end

  test 'should update sir_item' do
    patch sir_item_path( id: @sir_item, params:{ sir_item: { category: @sir_item.category }})
    assert_redirected_to sir_item_path( assigns( :sir_item ))
  end

  test 'should destroy sir_item' do
    sir_log = @sir_item.sir_log
    assert_difference( 'SirItem.count', -1 ) do
      delete sir_item_path( id: @sir_item )
    end
    assert_redirected_to sir_log_sir_items_path( sir_log )
  end

end
