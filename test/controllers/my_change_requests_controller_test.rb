require 'test_helper'
class MyChangeRequestsControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    @dbcr1 = db_change_requests( :dbcr_one )
    signon_by_user @account = accounts( :one )
  end

  test 'check class_attributes'  do
    get my_change_requests_path
    validate_feature_class_attributes FEATURE_ID_MY_CHANGE_REQUESTS, ApplicationController::FEATURE_ACCESS_USER
  end

  test 'should get index' do
    get my_change_requests_path
    assert_response :success
    assert_not_nil assigns( :dbcrs )
  end

  test 'should get new' do
    get new_my_change_request_path
    assert_response :success
  end

  test 'should create db_change_request' do
    assert_difference( 'DbChangeRequest.count' ) do
      post my_change_requests_path( params:{ db_change_request: { 
          requesting_account_id: @account,
          action: @dbcr1.action,
          feature_id: @dbcr1.feature_id,
          detail: @dbcr1.detail,
          request_text: @dbcr1.request_text }})
    end
    assert_redirected_to my_change_request_path( assigns( :dbcr ))
  end

  test 'should show db_change_request' do
    get my_change_request_path( id: @dbcr1 )
    assert_response :success
  end

  test 'should get edit' do
    get edit_my_change_request_path( id: @dbcr1 )
    assert_response :success
  end

  test 'should update db_change_request' do
    patch my_change_request_path( id: @dbcr1, params:{ db_change_request: {
          requesting_account_id: @account,
          action: @dbcr1.action,
          feature_id: @dbcr1.feature_id,
          detail: @dbcr1.detail,
          request_text: @dbcr1.request_text }})
    assert_redirected_to my_change_request_path( assigns( :dbcr ))
  end

  test 'should destroy db_change_request' do
    assert_difference( 'DbChangeRequest.count', -1) do
      delete my_change_request_path( id: @dbcr1 )
    end
    assert_redirected_to my_change_requests_path
  end
end
