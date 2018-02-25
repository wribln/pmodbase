require 'test_helper'
class DsrStatusRecordsController1Test < ActionDispatch::IntegrationTest

  setup do
    # set maximum permission
    @account = accounts( :one )
    pg = @account.permission4_groups.where( feature_id: FEATURE_ID_DSR_STATUS_RECORDS )
    pg[ 0 ].to_read = 1
    pg[ 0 ].to_update = 1
    pg[ 0 ].to_create = 1
    pg[ 0 ].save
    signon_by_user( @account )
    @dsr_status_record = dsr_status_records( :dsr_rec_two )
  end

  test 'check class_attributes' do
    get dsr_status_records_path
    validate_feature_class_attributes FEATURE_ID_DSR_STATUS_RECORDS, ApplicationController::FEATURE_ACCESS_INDEX,
      ApplicationController::FEATURE_CONTROL_GRPWF, 1
  end

  test 'should get index' do
    get dsr_status_records_path
    assert_response :success
    refute_nil assigns( :dsr_status_records )
    refute_nil assigns( :filter_states )
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should get new' do
    assert @account.permission_for_task?( FEATURE_ID_DSR_STATUS_RECORDS, 0, 0 )
    assert_equal [ 0 ],@account.permitted_workflows( FEATURE_ID_DSR_STATUS_RECORDS )
    get new_dsr_status_record_path
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should add' do
    get add_dsr_status_record_path( id: @dsr_status_record )
    assert_response :success
    assert_equal assigns( :dsr_previous_record ), @dsr_status_record.id, 'must always be set for add'
    assert assigns( :dsr_show_add_checkbox ).is_a?( FalseClass ), 'according to fixture :dsr_rec_two'
  end

  test 'should get info' do
    get dsr_workflow_info_path
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should show dsr entry' do
    get dsr_status_record_path( id: @dsr_status_record )
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should create dsr_status_record' do
    assert_difference( 'DsrStatusRecord.count' ) do
      post dsr_status_records_path( params:{ dsr_status_record: {
        current_status:  0,
        title:           @dsr_status_record.title,
        sender_group_id: @dsr_status_record.sender_group_id }})
    end
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
  end

  test 'cannot create dsr_status_record due to errors' do
    assert_difference( 'DsrStatusRecord.count', 0 ) do
      post dsr_status_records_path( params:{ dsr_status_record: {
        title:           nil,
        sender_group_id: @dsr_status_record.sender_group_id }})
    end
    assert_response :success
  end

  test 'should get edit' do
    get edit_dsr_status_record_path( id: @dsr_status_record )
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should update dsr_status_record' do
    patch dsr_status_record_path( id: @dsr_status_record, params:{
      dsr_status_record: { current_status: @dsr_status_record.current_status },
      next_status_task: 0 })
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'cannot update due to error' do
    patch dsr_status_record_path( id: @dsr_status_record, params:{
      dsr_status_record: { title: nil },
      next_status_task: 0 })
    assert_response :success
  end

  # Make sure document can only be updated when the current_user
  # has the respective permission(s) for the task/status and the group!

  test 'document update not permitted for this user' do
    switch_to_user( accounts( :wop ))
    patch dsr_status_record_path( id: @dsr_status_record, params:{
      dsr_status_record: { current_status: @dsr_status_record.current_status },
      next_status_task: 0 })
    check_for_cr
  end

  test 'document update not permitted for this user''s group' do
    switch_to_user( accounts( :two ))
    patch dsr_status_record_path( id: @dsr_status_record, params:{
      dsr_status_record: { current_status: @dsr_status_record.current_status },
      next_status_task: 0 })
    check_for_cr
  end

  test 'should destroy dsr_status_record' do
    assert_difference('DsrStatusRecord.count', -1) do
      delete dsr_status_record_path( id: @dsr_status_record )
    end
    assert_redirected_to dsr_status_records_path
  end

end
