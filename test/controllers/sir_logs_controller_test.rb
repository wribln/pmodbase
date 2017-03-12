require 'test_helper'

class SirLogsControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
    @sir_log = sir_logs( :sir_log_one )
  end

  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_SIR_LOGS, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :sir_logs )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create sir_log' do
    assert_difference( 'SirLog.count' ) do
      post :create, sir_log: { label: @sir_log.label, code: 'XX', owner_account_id: @account.id }
    end
    assert_redirected_to sir_log_path( assigns( :sir_log ))
  end

  test 'should show sir_log' do
    get :show, id: @sir_log
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @sir_log
    assert_response :success
  end

  test 'should update sir_log' do
    patch :update, id: @sir_log, sir_log: { label: @sir_log.label }
    assert_redirected_to sir_log_path( assigns( :sir_log ))
  end

  test 'should destroy sir_log 1' do
    assert_difference( 'SirLog.count', -1 ) do
      delete :destroy, id: @sir_log
    end
    assert_redirected_to sir_logs_path
  end

  test 'should destroy sir_log 2' do
    # add more entries to item
    si = sir_items( :one )
    assert_difference( 'SirEntry.count', 1 ) do
      si.sir_entries.create( rec_type: 1, orig_group_id:  groups( :group_one ).id, resp_group_id: groups( :group_two ).id )
    end
    assert_difference( 'SirLog.count', -1 ) do
      delete :destroy, id: @sir_log
    end
    assert_redirected_to sir_logs_path
  end    

end
