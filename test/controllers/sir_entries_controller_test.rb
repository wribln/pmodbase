require 'test_helper'
class SirEntriesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @sir_entry = sir_entries( :one )
    signon_by_user accounts( :one )
  end

  test 'should get new' do
    get new_sir_item_sir_entry_path( sir_item_id: @sir_entry.sir_item )
    assert_response :success
  end

  test 'should create sir_entry' do
    assert_difference('SirEntry.count') do
      post  sir_item_sir_entries_path( sir_item_id: @sir_entry.sir_item, params:{ sir_entry: { rec_type: 1, resp_group_id: @sir_entry.resp_group_id }})
      se = assigns( :sir_entry )
      si = assigns( :sir_item )
      assert se.valid?, se.errors.messages
    end
  end

  test 'should show sir_entry' do
    get sir_entry_path( id: @sir_entry )
    assert_response :success
  end

  test 'should get edit' do
    get edit_sir_entry_path( id: @sir_entry )
    assert_response :success
  end

  test 'should update sir_entry' do
    patch sir_entry_path( id: @sir_entry, params:{ sir_entry: { due_date: @sir_entry.due_date, resp_group_id: @sir_entry.resp_group_id }})
    assert_redirected_to sir_entry_path( assigns( :sir_entry ))
  end

  test 'should destroy sir_entry' do
    assert_difference('SirEntry.count', -1) do
      delete sir_entry_path( id: @sir_entry )
    end
    assert_redirected_to sir_item_path, sir_item_id: @sir_entry.sir_item_id
  end

end
