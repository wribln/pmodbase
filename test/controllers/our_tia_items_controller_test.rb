require 'test_helper'
class OurTiaItemsControllerTest < ActionController::TestCase

  setup do
    @tia_item = tia_items( :tia_item_one )
    @tia_list = @tia_item.tia_list
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "should get index" do
    get :index, my_tia_list_id: @tia_list
    assert_response :success
    assert_not_nil assigns( :tia_items )
    assert_not_nil assigns( :member_list )
  end

  test "should get new" do
    get :new, my_tia_list_id: @tia_list
    assert_not_nil assigns( :member_list )
    assert_response :success
  end

  test "should create tia_item" do
    assert_difference('TiaItem.count') do
      post :create, tia_item: {
        account_id: @tia_item.account_id,
        description: @tia_item.description,
        prio:       @tia_item.prio,
        seqno:    ( @tia_item.seqno + 1 ),
        status:     @tia_item.status,
        tia_list_id: @tia_item.tia_list_id },
        my_tia_list_id: @tia_list
    end
    assert_not_nil assigns( :member_list )
    assert_redirected_to our_tia_item_path( assigns( :tia_item ))
  end

  test "should show tia_item" do
    get :show, id: @tia_item
    assert_response :success
  end

  test "should show tia_item history" do
    get :info, id: @tia_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tia_item
    assert_response :success
    assert_not_nil assigns( :member_list )
  end

  test "should update tia_item" do
    patch :update, id: @tia_item, tia_item: { 
      comment:     @tia_item.comment + '+',
      tia_list_id: @tia_item.tia_list_id }
    assert_not_nil assigns( :member_list )
    assert_redirected_to our_tia_item_path( assigns( :tia_item ))
  end

  test "no changes requested by update tia_item" do
    patch :update, id: @tia_item, tia_item: { 
      comment:     @tia_item.comment,
      tia_list_id: @tia_item.tia_list_id }
    assert_redirected_to our_tia_item_path( assigns( :tia_item ))
    assert_not_nil assigns( :member_list )
  end

  test "should destroy tia_item" do
    assert_difference('TiaItem.count', -1) do
      delete :destroy, id: @tia_item
    end
    assert_redirected_to my_tia_list_our_tia_items_path( @tia_list )
  end

  test 'create status report' do
    get :index, my_tia_list_id: @tia_list, format: :doc
    assert_response :success
    assert_not_nil assigns( :tia_items )
    assert_not_nil assigns( :tia_stats )
  end

end
