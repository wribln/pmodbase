require 'test_helper'
class AccountsControllerAccessTest < ActionDispatch::IntegrationTest

  test 'check class_attributes'  do
    signon_by_user accounts( :one )
    get accounts_path
    validate_feature_class_attributes FEATURE_ID_ACCOUNTS_AND_PERMISSIONS, ApplicationController::FEATURE_ACCESS_SOME
  end

  # index

  test 'index is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    get accounts_path
    check_for_cr
  end

  test 'should not get index' do
    get accounts_path
    assert_response :unauthorized
  end

  # show

  test 'show is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    get account_path( id: accounts( :three ))
    check_for_cr
  end

  test 'should not get show' do
    get edit_account_path( id: accounts( :three ))
    assert_response :unauthorized
  end

  # edit

  test 'edit is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    get edit_account_path( id: accounts( :three ))
    check_for_cr
  end

  test 'should not get edit' do
    get edit_account_path( id: accounts( :three ))
    assert_response :unauthorized
  end

  # new

  test 'new is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    assert_difference( 'Account.count', 0 ) { get new_account_path }
    check_for_cr
  end

  test 'should not get new' do
    assert_difference( 'Account.count', 0 ) { get new_account_path }
    assert_response :unauthorized
  end

  # update

  test 'update is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    patch account_path( id: accounts( :three ))
    check_for_cr
  end

  test 'update is  not permitted' do
    patch account_path( id: accounts( :three ))
    assert_response :unauthorized
  end

  # create

  test 'create is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    assert_difference( 'Account.count', 0 ) { post accounts_path }
    check_for_cr
  end

  test 'create is not permitted' do
    assert_difference( 'Account.count', 0 ) { post accounts_path }
    assert_response :unauthorized
  end

  # delete

  test 'delete is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    assert_difference( 'Abbreviation.count', 0 ) { delete account_path( id: accounts( :three )) }
    check_for_cr
  end

  test 'delete is not permitted' do
    assert_difference( 'Abbreviation.count', 0 ) { delete account_path( id: accounts( :three )) }
    assert_response :unauthorized
  end

end
