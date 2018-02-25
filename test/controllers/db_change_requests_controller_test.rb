require 'test_helper'
class DbChangeRequestsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @dbcr1 = db_change_requests( :dbcr_one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get db_change_requests_path
    validate_feature_class_attributes FEATURE_ID_DB_CHANGE_REQUESTS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'verify fixtures' do
    assert_not_nil @dbcr1.id
    assert_not_nil @dbcr1.requesting_account_id
    assert_equal accounts( :one ).id, @dbcr1.requesting_account_id 
    assert_nil @dbcr1.responsible_account_id
    assert_nil @dbcr1.detail
    assert_equal 'test1', @dbcr1.action
    assert 0, @dbcr1.status
    assert_not @dbcr1.request_text.blank?
  end

  test 'should get index' do
    get db_change_requests_path
    assert_response :success
    assert_not_nil assigns( :dbcrs )
  end

  test 'should get new' do
    get new_db_change_request_path
    assert_response :success
  end

  test 'should create db_change_request' do
    assert_difference( 'DbChangeRequest.count' ) do
      post db_change_requests_path( params:{ db_change_request: {
        requesting_account_id: accounts( :one ).id, 
        status: 0,
        request_text: 'This is a request!' }})
    end
    assert_redirected_to db_change_request_path( assigns( :dbcr ))
  end

  test 'should show db_change_request' do
    get db_change_request_path( id: @dbcr1 )
    assert_response :success
  end

  test 'should get edit' do
    get edit_db_change_request_path( id: @dbcr1 )
    assert_response :success
  end

  test 'should update db_change_request' do
    patch db_change_request_path( id: @dbcr1, params:{ db_change_request: { 
      requesting_account_id: accounts( :one ).id,
      status: 0,
      request_text: 'Yet another request.' }})
    assert_redirected_to db_change_request_path( assigns ( :dbcr ))
  end

  test 'should destroy db_change_request' do
    assert_difference('DbChangeRequest.count', -1) do
      delete db_change_request_path( id: @dbcr1 )
    end
    assert_redirected_to db_change_requests_path
  end
end
