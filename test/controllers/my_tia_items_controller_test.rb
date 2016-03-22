require 'test_helper'
class MyTiaItemsControllerTest < ActionController::TestCase

  setup do
    @tia_item = tia_items( :tia_item_one )
    @tia_list = @tia_item.tia_list
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :tia_items )
  end

  test "new is not permitted here" do
    get :new
    assert_response :forbidden
  end

  test "should not create tia_item" do
    post :create, tia_item: {
      account_id: @tia_item.account_id,
      description: @tia_item.description,
      prio:       @tia_item.prio,
      seqno:    ( @tia_item.seqno + 1 ),
      status:     @tia_item.status,
      tia_list_id: @tia_item.tia_list_id }
    assert_response :forbidden
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
  end

  test "should update tia_item" do
    patch :update, id: @tia_item, tia_item: { comment: 'this was changed' }
    assert_redirected_to my_tia_item_path( assigns( :tia_item ))
  end

  test "should not destroy tia_item" do
    delete :destroy, id: @tia_item
    assert_response :forbidden 
  end

end
