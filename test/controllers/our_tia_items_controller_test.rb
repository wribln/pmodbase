require 'test_helper'
class OurTiaItemsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @tia_item = tia_items( :tia_item_one )
    @tia_list = @tia_item.tia_list
    signon_by_user accounts( :one )
  end

  test 'should get index' do
    get my_tia_list_our_tia_items_path( my_tia_list_id: @tia_list )
    assert_response :success
    assert_not_nil assigns( :tia_items )
    assert_not_nil assigns( :member_list )
  end

  test 'should get new' do
    get new_my_tia_list_our_tia_item_path( my_tia_list_id: @tia_list )
    assert_not_nil assigns( :member_list )
    assert_response :success
  end

  test 'should create tia_item' do
    assert_difference( 'TiaItem.count' ) do
      post my_tia_list_our_tia_items_path( my_tia_list_id: @tia_list, params:{ tia_item: {
        account_id: @tia_item.account_id,
        description: @tia_item.description,
        prio:       @tia_item.prio,
        seqno:    ( @tia_item.seqno + 1 ),
        status:     @tia_item.status,
        tia_list_id: @tia_item.tia_list_id }})
    end
    assert_nil assigns( :member_list )
    assert_redirected_to our_tia_item_path( assigns( :tia_item ))
  end

  test 'could not create tia_item due to error' do
    assert_difference( 'TiaItem.count', 0 ) do
      post my_tia_list_our_tia_items_path( my_tia_list_id: @tia_list, params:{ tia_item: {
        account_id: @tia_item.account_id,
        description: @tia_item.description,
        prio:        -1,
        seqno:     ( @tia_item.seqno + 1 ),
        status:     @tia_item.status,
        tia_list_id: @tia_item.tia_list_id }})
    end
    assert_not_nil assigns( :member_list )
    assert_template :new
    assert_response :success
  end

  test 'should show tia_item' do
    get our_tia_item_path( id: @tia_item )
    assert_response :success
  end

  test 'should show tia_item history' do
    get our_tia_item_info_path( id: @tia_item )
    assert_response :success
  end

  test 'should get edit' do
    get edit_our_tia_item_path( id: @tia_item )
    assert_response :success
    assert_not_nil assigns( :member_list )
  end

  test 'should update tia_item' do
    patch our_tia_item_path( id: @tia_item, params:{ tia_item: { 
      comment:     @tia_item.comment + '+',
      tia_list_id: @tia_item.tia_list_id }})
    assert_nil assigns( :member_list )
    assert_redirected_to our_tia_item_path( assigns( :tia_item ))
  end

  test 'no changes requested by update tia_item' do
    patch our_tia_item_path( id: @tia_item, params:{ tia_item: { 
      comment:     @tia_item.comment,
      tia_list_id: @tia_item.tia_list_id }})
    assert_nil assigns( :member_list )
    assert_redirected_to our_tia_item_path( assigns( :tia_item ))
  end

  test 'could not update tia_item' do
    patch our_tia_item_path( id: @tia_item, params:{ tia_item: { 
      comment:     @tia_item.comment,
      prio:        -1, 
      tia_list_id: @tia_item.tia_list_id }})
    assert_not_nil assigns( :member_list )
    assert_template :edit
    assert_response :success
  end

  test 'should destroy tia_item' do
    assert_difference('TiaItem.count', -1) do
      delete our_tia_item_path( id: @tia_item )
    end
    assert_redirected_to my_tia_list_our_tia_items_path( @tia_list )
  end

  test 'create status report' do
    get my_tia_list_our_tia_items_path( my_tia_list_id: @tia_list, format: :doc )
    assert_response :success
    assert_not_nil assigns( :tia_items )
    assert_not_nil assigns( :tia_stats )
  end

end
