require 'test_helper'

class SirItemsControllerTest < ActionController::TestCase
  setup do
    @sir_item = sir_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sir_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sir_item" do
    assert_difference('SirItem.count') do
      post :create, sir_item: { archived: @sir_item.archived, category: @sir_item.category, cfr_record_id: @sir_item.cfr_record_id, desc: @sir_item.desc, group_id: @sir_item.group_id, label: @sir_item.label, phase_id: @sir_item.phase_id, ref_id: @sir_item.ref_id, status: @sir_item.status }
    end

    assert_redirected_to sir_item_path(assigns(:sir_item))
  end

  test "should show sir_item" do
    get :show, id: @sir_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sir_item
    assert_response :success
  end

  test "should update sir_item" do
    patch :update, id: @sir_item, sir_item: { archived: @sir_item.archived, category: @sir_item.category, cfr_record_id: @sir_item.cfr_record_id, desc: @sir_item.desc, group_id: @sir_item.group_id, label: @sir_item.label, phase_id: @sir_item.phase_id, ref_id: @sir_item.ref_id, status: @sir_item.status }
    assert_redirected_to sir_item_path(assigns(:sir_item))
  end

  test "should destroy sir_item" do
    assert_difference('SirItem.count', -1) do
      delete :destroy, id: @sir_item
    end

    assert_redirected_to sir_items_path
  end
end
