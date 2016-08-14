require 'test_helper'
class MyTiaListsControllerAccessTest < ActionController::TestCase
  tests MyTiaListsController

  test 'check class attributes' do
    validate_feature_class_attributes FEATURE_ID_MY_TIA_LISTS, 
      ApplicationController::FEATURE_ACCESS_SOME,
      ApplicationController::FEATURE_CONTROL_CUG
  end

  test 'index is permitted when user has access to feature' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    get :index
    check_for_cr
  end

  test 'look for two lists for user wop' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    p = Permission4Group.new( account_id: accounts( :wop ).id, feature_id: FEATURE_ID_MY_TIA_LISTS, group_id: 0, to_index: 1 )
    assert_difference( 'Permission4Group.count' ) do
      p.save
    end
    get :index
    assert_response :success
    tl = assigns( :tia_lists )
    assert_equal 2, tl.length
    assert_includes tl, tia_lists( :tia_list_one ), ':wop should be deputy of :tia_list_one'
    assert_includes tl, tia_lists( :tia_list_two ), ':wop should be owner of :tia_list_two'
  end

  test 'look for one list for user one' do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
    get :index
    assert_response :success
    tl = assigns( :tia_lists )
    assert_equal 1, tl.length
    assert_includes tl, tia_lists( :tia_list_one ), ':one should be owner of :tia_list_one'
    assert_not_includes tl, tia_lists( :tia_list_two ), ':one is neither owner nor deputy of :tia_list_two'
  end

  test 'index is not authorized if no user' do
    @account = nil
    session[ :current_user_id ] = nil
    get :index
    assert_response :unauthorized
  end
 
end
