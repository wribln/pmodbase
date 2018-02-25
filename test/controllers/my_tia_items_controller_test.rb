require 'test_helper'
class MyTiaItemsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @tia_item = tia_items( :tia_item_one )
    @tia_list = @tia_item.tia_list
    signon_by_user @account = accounts( :one )
  end

  test 'should get index' do
    get my_tia_items_path
    assert_response :success
    tia_item_list = assigns( :tia_items )
    refute tia_item_list.empty?
    assert_equal 1, tia_item_list.length
    # because fixture 2 belongs to different account!
  end

  test 'new is not permitted here' do
    get new_my_tia_item_path
    assert_response :forbidden
  end

  test 'should not create tia_item' do
    post my_tia_items_path( params:{ tia_item: {
      account_id: @tia_item.account_id,
      description: @tia_item.description,
      prio:       @tia_item.prio,
      seqno:    ( @tia_item.seqno + 1 ),
      status:     @tia_item.status,
      tia_list_id: @tia_item.tia_list_id }})
    assert_response :forbidden
  end

  test 'should show tia_item' do
    get my_tia_item_path( id: @tia_item )
    assert_response :success
  end

  test 'should show tia_item history' do
    get my_tia_item_info_path( id: @tia_item )
    assert_response :success
  end

  test 'should get edit' do
    get edit_my_tia_item_path( id: @tia_item )
    assert_response :success
  end

  test 'should update tia_item' do
    patch my_tia_item_path( id: @tia_item, params:{ tia_item: { comment: 'this was changed' }})
    assert_redirected_to my_tia_item_path( assigns( :tia_item ))
  end

  test 'should not destroy tia_item' do
    delete my_tia_item_path( id: @tia_item )
    assert_response :forbidden 
  end

end
