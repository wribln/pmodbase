require 'test_helper'
class AccountsControllerAccessTest < ActionController::TestCase
  tests AccountsController

  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_ACCOUNTS_AND_PERMISSIONS, ApplicationController::FEATURE_ACCESS_SOME
  end

  # index

  test 'index is not permitted but results in cr form' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    get :index
    check_for_cr
  end

  test 'should not get index' do
    @account = nil
    session[ :current_user_id ] = nil
    get :index
    assert_response :unauthorized
  end

  # show

  test 'show is not permitted but results in cr form' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    get :show, id: accounts( :three )
    check_for_cr
  end

  test 'should not get show' do
    @account = nil
    session[ :current_user_id ] = nil
    get :edit, id: accounts( :three )
    assert_response :unauthorized
  end

  # edit

  test 'edit is not permitted but results in cr form' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    get :edit, id: accounts( :three )
    check_for_cr
  end

  test 'should not get edit' do
    @account = nil
    session[ :current_user_id ] = nil
    get :edit, id: accounts( :three )
    assert_response :unauthorized
  end

  # new

  test 'new is not permitted but results in cr form' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    assert_difference( 'Account.count', 0 ) { get :new }
    check_for_cr
  end

  test 'should not get new' do
    @account = nil
    session[ :current_user_id ] = nil
    assert_difference( 'Account.count', 0 ) { get :new }
    assert_response :unauthorized
  end

  # update

  test 'update is not permitted but results in cr form' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    patch :update, id: accounts( :three )
    check_for_cr
  end

  test 'update is  not permitted' do
    @account = nil
    session[ :current_user_id ] = nil
    patch :update, id: accounts( :three )
    assert_response :unauthorized
  end

  # create

  test 'create is not permitted but results in cr form' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    assert_difference( 'Account.count', 0 ) { post :create }
    check_for_cr
  end

  test 'create is not permitted' do
    @account = nil
    session[ :current_user_id ] = nil
    assert_difference( 'Account.count', 0 ) { post :create }
    assert_response :unauthorized
  end

  # delete

  test 'delete is not permitted but results in cr form' do
    @account = accounts( :wop )
    session[ :current_user_id ] = accounts( :wop ).id
    assert_difference( 'Abbreviation.count', 0 ) { delete :destroy, id: accounts( :three )}
    check_for_cr
  end

  test 'delete is not permitted' do
    @account = nil
    session[ :current_user_id ] = nil
    assert_difference( 'Abbreviation.count', 0 ) { delete :destroy, id: accounts( :three )}
    assert_response :unauthorized
  end

end
