require 'test_helper'
class MyTiaListsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @tia_list = tia_lists( :tia_list_one )
    signon_by_user @account = accounts( :one )
  end

  test 'check class attributes' do
    get my_tia_lists_path
    validate_feature_class_attributes FEATURE_ID_MY_TIA_LISTS, 
      ApplicationController::FEATURE_ACCESS_SOME,
      ApplicationController::FEATURE_CONTROL_CUG
  end

  test 'should get index' do
    get my_tia_lists_path
    assert_response :success
    assert_not_nil assigns( :tia_lists )
  end

  test 'should get new' do
    get new_my_tia_list_path
    assert_response :success
  end

  test 'should create tia_list' do
    assert_difference( 'TiaList.count' ) do
      post my_tia_lists_path( params:{ tia_list: { code: @tia_list.code + '+', label: @tia_list.label, owner_account_id: @account.id }})
    end
    assert_redirected_to my_tia_list_path( assigns( :tia_list ))
  end

  test 'should not create tia_list with same name' do
    assert_no_difference( 'TiaList.count' ) do
      post my_tia_lists_path( params:{ tia_list: { code: @tia_list.code, label: @tia_list.label, owner_account_id: @account.id }})
    end
    assert_response :success
  end

  test 'attempt to assign owner nil and deputy nil' do
    assert_no_difference 'TiaList.count' do
      post my_tia_lists_path( params:{ tia_list: { code: @tia_list.code + '+', label: @tia_list.label, owner_account_id: nil }})
    end
    assert_response :success
  end

  test 'attempt to assign bad owner and deputy nil' do
    assert_no_difference 'TiaList.count' do
      post my_tia_lists_path( params:{ tia_list: { code: @tia_list.code + '+', label: @tia_list.label, owner_account_id: accounts( :two ).id }})
    end
    assert_response :success
  end

  test 'should show tia_list' do
    get my_tia_list_path( id: @tia_list )
    assert_response :success
  end

  test 'should get edit' do
    get edit_my_tia_list_path( id: @tia_list )
    assert_response :success
  end

  test 'should update tia_list' do
    patch my_tia_list_path( id: @tia_list, params:{ tia_list: {
      code:               @tia_list.code,
      label:              @tia_list.label,
      deputy_account_id:  @tia_list.deputy_account_id }})
    assert_redirected_to my_tia_list_path( assigns( :tia_list ))
  end

  test 'should destroy tia_list' do
    assert_difference( 'TiaList.count', -1) do
      delete my_tia_list_path( id: @tia_list )
    end
    assert_redirected_to my_tia_lists_path
  end

end
