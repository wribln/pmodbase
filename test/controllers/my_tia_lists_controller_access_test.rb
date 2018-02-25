require 'test_helper'
class MyTiaListsControllerAccessTest < ActionDispatch::IntegrationTest

  test 'check class attributes' do
    signon_by_user accounts( :wop )
    get my_tia_lists_path
    validate_feature_class_attributes FEATURE_ID_MY_TIA_LISTS, 
      ApplicationController::FEATURE_ACCESS_SOME,
      ApplicationController::FEATURE_CONTROL_CUG
  end

  test 'index is permitted when user has access to feature' do
    signon_by_user accounts( :wop )
    get my_tia_lists_path
    check_for_cr
  end

  test 'look for two lists for user wop' do
    signon_by_user @account = accounts( :wop )
    p = Permission4Group.new( account_id: @account.id, feature_id: FEATURE_ID_MY_TIA_LISTS, group_id: 0, to_index: 1 )
    assert_difference( 'Permission4Group.count' ) do
      p.save
    end
    get my_tia_lists_path
    assert_response :success
    tl = assigns( :tia_lists )
    assert_equal 2, tl.length
    assert_includes tl, tia_lists( :tia_list_one ), ':wop should be deputy of :tia_list_one'
    assert_includes tl, tia_lists( :tia_list_two ), ':wop should be owner of :tia_list_two'
  end

  test 'look for one list for user one' do
    @account = accounts( :one )
    signon_by_user @account
    get my_tia_lists_path
    assert_response :success
    tl = assigns( :tia_lists )
    assert_equal 1, tl.length
    assert_includes tl, tia_lists( :tia_list_one ), ':one should be owner of :tia_list_one'
    assert_not_includes tl, tia_lists( :tia_list_two ), ':one is neither owner nor deputy of :tia_list_two'
  end

  test 'index is not authorized if no user' do
    get my_tia_lists_path
    assert_response :unauthorized
  end
 
end
