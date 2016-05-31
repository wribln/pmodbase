require 'test_helper'
class DsrStatusRecordsController0Test < ActionController::TestCase
  tests DsrStatusRecordsController

  setup do
    # set maximum permission
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
    @dsr_status_record = dsr_status_records( :dsr_rec_two )
  end

  test 'check class_attributes' do
    validate_feature_class_attributes FEATURE_ID_DSR_STATUS_RECORDS, ApplicationController::FEATURE_ACCESS_INDEX,
      ApplicationController::FEATURE_CONTROL_GRPWF, 1
  end

  test 'should get index' do
    get :index
    assert_response :success
    refute_nil assigns( :dsr_status_records )
    refute_nil assigns( :filter_states )
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should get new' do
    assert @account.permission_for_task?( FEATURE_ID_DSR_STATUS_RECORDS, 0, 0 )
    assert_equal [ 0 ],@account.permitted_workflows( FEATURE_ID_DSR_STATUS_RECORDS )
    get :new
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should add' do
    get :add, id: @dsr_status_record
    assert_response :success
    assert_equal assigns( :dsr_previous_record ), @dsr_status_record.id, 'must always be set for add'
    assert assigns( :dsr_show_add_checkbox ).is_a?( FalseClass ), 'according to fixture :dsr_rec_two'
  end

  test 'should get info' do
    get :info_workflow
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should show dsr entry' do
    get :show, id: @dsr_status_record
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should create dsr_status_record' do
    assert_difference( 'DsrStatusRecord.count' ) do
      post :create, dsr_status_record: {
        title:           @dsr_status_record.title,
        sender_group_id: @dsr_status_record.sender_group_id }
    end
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
  end

  test 'cannot create dsr_status_record due to errors' do
    assert_difference( 'DsrStatusRecord.count', 0 ) do
      post :create, dsr_status_record: {
        title:           nil,
        sender_group_id: @dsr_status_record.sender_group_id }
    end
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @dsr_status_record
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should update dsr_status_record' do
    patch :update, id: @dsr_status_record,
      dsr_status_record: { current_status: @dsr_status_record.current_status },
      next_status_task: 0
    assert assigns( :dsr_status_record ).errors.empty?
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'cannot update due to error' do
    patch :update, id: @dsr_status_record,
      dsr_status_record: { title: nil },
      next_status_task: 0
    assert_response :success
  end

  # Make sure document can only be updated when the current_user
  # has the respective permission(s) for the task/status and the group!

  test 'document update not permitted for this user' do
    session[ :current_user_id ] = accounts( :account_wop ).id
    patch :update, id: @dsr_status_record,
      dsr_status_record: { current_status: @dsr_status_record.current_status },
      next_status_task: 0
    check_for_cr
  end

  test 'document update not permitted for this user''s group' do
    session[ :current_user_id ] = accounts( :account_two )
    patch :update, id: @dsr_status_record,
      dsr_status_record: { current_status: @dsr_status_record.current_status },
      next_status_task: 0
    check_for_cr
  end

  test 'should destroy dsr_status_record' do
    assert_difference('DsrStatusRecord.count', -1) do
      delete :destroy, id: @dsr_status_record
    end
    assert_redirected_to dsr_status_records_path
  end

  # make sure the array used by update_document_status is sufficiently
  # sized by testing the highest status for a record

  test 'update document status' do
    assert_equal 1, @dsr_status_record.current_status
    assert_equal 1, @dsr_status_record.current_task
    patch :update, id: @dsr_status_record,
      dsr_status_record: { title: 'withdrawn' },
      next_status_task: 3
    assert assigns( :dsr_status_record ).errors.empty?
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
    assert_equal 18, assigns( :dsr_status_record ).current_status
    assert_equal 10, assigns( :dsr_status_record ).current_task
  end

end
