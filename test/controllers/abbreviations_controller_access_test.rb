# test FEATURE_ACCESS_INDEX control - the controller is just a sample

require 'test_helper'
class AbbreviationsControllerAccessTest < ActionController::TestCase
  tests AbbreviationsController

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_ABBREVIATIONS, ApplicationController::FEATURE_ACCESS_INDEX
  end

  # index

  test "index is permitted for all valid accounts" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    get :index
    assert_response :success
    assert_select 'h2', I18n.t( 'abbreviations.index.form_title' )
  end

  test "should not get index" do
    @account = nil
    session[ :current_user_id ] = nil
    get :index
    assert_response :unauthorized
  end

  # show

  test "show is not permitted but results in cr form" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    get :show, id: abbreviations( :sag )
    check_for_cr
  end

  test "should not get show" do
    @account = nil
    session[ :current_user_id ] = nil
    get :edit, id: abbreviations( :sag )
    assert_response :unauthorized
  end

  # edit

  test "edit is not permitted but results in cr form" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    get :edit, id: abbreviations( :sag )
    check_for_cr
  end

  test "should not get edit" do
    @account = nil
    session[ :current_user_id ] = nil
    get :edit, id: abbreviations( :sag )
    assert_response :unauthorized
  end

  # new

  test "new is not permitted but results in cr form" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    assert_difference( 'Abbreviation.count', 0 ) { get :new }
    check_for_cr
  end

  test "should not get new" do
    @account = nil
    session[ :current_user_id ] = nil
    assert_difference( 'Abbreviation.count', 0 ) { get :new }
    assert_response :unauthorized
  end

  # update

  test "update is not permitted but results in cr form" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    patch :update, id: abbreviations( :sag )
    check_for_cr
  end

  test "update is  not permitted" do
    @account = nil
    session[ :current_user_id ] = nil
    patch :update, id: abbreviations( :sag )
    assert_response :unauthorized
  end

  # create

  test "create is not permitted but results in cr form" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    assert_difference( 'Abbreviation.count', 0 ) { post :create }
    check_for_cr
  end

  test "create is not permitted" do
    @account = nil
    session[ :current_user_id ] = nil
    assert_difference( 'Abbreviation.count', 0 ) { post :create }
    assert_response :unauthorized
  end

  # delete

  test "delete is not permitted but results in cr form" do
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
    assert_difference( 'Abbreviation.count', 0 ) { delete :destroy, id: abbreviations( :sag )}
    check_for_cr
  end

  test "delete is not permitted" do
    @account = nil
    session[ :current_user_id ] = nil
    assert_difference( 'Abbreviation.count', 0 ) { delete :destroy, id: abbreviations( :sag )}
    assert_response :unauthorized
  end

end
