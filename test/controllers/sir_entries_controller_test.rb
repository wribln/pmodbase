require 'test_helper'
class SirEntriesControllerTest < ActionController::TestCase

  setup do
    @sir_entry = sir_entries( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'should get new' do
    puts @sir_entry.sir_item_id
    get :new, sir_item_id: @sir_entry.sir_item
    assert_response :success
  end
#
#  test 'should create sir_entry' do
#    assert_difference('SirEntry.count') do
#      post :create, sir_entry: { desc: @sir_entry.desc, due_date: @sir_entry.due_date, group_id: @sir_entry.group_id, no_sub_req: @sir_entry.no_sub_req, parent_id: @sir_entry.parent_id, sir_item_id: @sir_entry.sir_item_id, type: @sir_entry.type }
#    end
#
#    assert_redirected_to sir_entry_path(assigns(:sir_entry))
#  end
#
#  test 'should show sir_entry' do
#    get :show, id: @sir_entry
#    assert_response :success
#  end
#
#  test 'should get edit' do
#    get :edit, id: @sir_entry
#    assert_response :success
#  end
#
#  test 'should update sir_entry' do
#    patch :update, id: @sir_entry, sir_entry: { desc: @sir_entry.desc, due_date: @sir_entry.due_date, group_id: @sir_entry.group_id, no_sub_req: @sir_entry.no_sub_req, parent_id: @sir_entry.parent_id, sir_item_id: @sir_entry.sir_item_id, type: @sir_entry.type }
#    assert_redirected_to sir_entry_path(assigns(:sir_entry))
#  end
#
#  test 'should destroy sir_entry' do
#    assert_difference('SirEntry.count', -1) do
#      delete :destroy, id: @sir_entry
#    end
#
#    assert_redirected_to sir_entries_path
#  end
end
