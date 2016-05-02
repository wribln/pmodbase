require 'test_helper'

class PcpItemsControllerTest < ActionController::TestCase
  setup do
    @pcp_item = pcp_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pcp_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pcp_item" do
    assert_difference('PcpItem.count') do
      post :create, pcp_item: { descr: @pcp_item.descr, item_status: @pcp_item.item_status, pcp_step_id: @pcp_item.pcp_step_id, pcp_subject_id: @pcp_item.pcp_subject_id, reference: @pcp_item.reference, seq_no: @pcp_item.seq_no }
    end

    assert_redirected_to pcp_item_path(assigns(:pcp_item))
  end

  test "should show pcp_item" do
    get :show, id: @pcp_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pcp_item
    assert_response :success
  end

  test "should update pcp_item" do
    patch :update, id: @pcp_item, pcp_item: { descr: @pcp_item.descr, item_status: @pcp_item.item_status, pcp_step_id: @pcp_item.pcp_step_id, pcp_subject_id: @pcp_item.pcp_subject_id, reference: @pcp_item.reference, seq_no: @pcp_item.seq_no }
    assert_redirected_to pcp_item_path(assigns(:pcp_item))
  end

  test "should destroy pcp_item" do
    assert_difference('PcpItem.count', -1) do
      delete :destroy, id: @pcp_item
    end

    assert_redirected_to pcp_items_path
  end
end
