require 'test_helper'
class AllTiaListsControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @tia_list = tia_lists( :tia_list_one )
    @account = accounts( :one )
  end

  test 'check class attributes' do
    get all_tia_lists_path
    validate_feature_class_attributes FEATURE_ID_ALL_TIA_LISTS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get all_tia_lists_path
    assert_response :success
    assert_not_nil assigns( :tia_lists )
  end

  test 'should get new' do
    get new_all_tia_list_path
    assert_response :success
  end

  test 'should create tia_list' do
    assert_difference( 'TiaList.count' ) do
      post all_tia_lists_path, params:{ tia_list: { code: @tia_list.code + '+', label: @tia_list.label, owner_account_id: @account.id }}
    end
    assert_redirected_to all_tia_list_path( assigns( :tia_list ))
  end

  test 'should show tia_list' do
    get all_tia_list_path( id: @tia_list )
    assert_response :success
  end

  test 'should get edit' do
    get edit_all_tia_list_path( id: @tia_list )
    assert_response :success
  end

  test 'should update tia_list' do
    patch all_tia_list_path( id: @tia_list, params:{ tia_list: { code: @tia_list.code, label: @tia_list.label, owner_account_id: @account }})
    assert_redirected_to all_tia_list_path( assigns( :tia_list ))
  end

  test 'should destroy tia_list' do
    assert_difference( 'TiaList.count', -1) do
      delete all_tia_list_path( id: @tia_list )
    end
    assert_redirected_to all_tia_lists_path
  end
  
end
