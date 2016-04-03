require 'test_helper'
class RfcStatusRecordsControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :account_one )
    session[ :current_user_id ] = @account.id
    @rfc_status_record = rfc_status_records( :rfc_one )
  end

  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_RFC_STATUS_RECORDS,
      ApplicationController::FEATURE_ACCESS_INDEX,
      ApplicationController::FEATURE_CONTROL_GRPWF,
      3
  end

  test 'permission fixture' do
    p = permission4_flows( :rsr )
    assert_equal FEATURE_ID_RFC_STATUS_RECORDS, p.feature_id
    assert_equal 0, p.workflow_id
    assert p.permission_for_creation?
    assert p.permission_for_task?( 1 )
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get info' do
    get :info
    assert_response :success
  end

  test 'should get statistics' do
    get :stats 
    assert_response :success
    refute_nil assigns( :stats )
  end

  test 'should get new' do
    assert @account.permission_for_task?( FEATURE_ID_RFC_STATUS_RECORDS, 0, 0 )
    assert_equal [0],@account.permitted_workflows( FEATURE_ID_RFC_STATUS_RECORDS )
    get :new
    assert_response :success
    refute_nil assigns( :rfc_status_record )
    refute_nil assigns( :allowed_workflows )
  end

  test 'should create rfc_status_record' do
    assert_difference('RfcStatusRecord.count') do
      post :create, rfc_status_record: { rfc_type: @rfc_status_record.rfc_type }
    end
    assert_redirected_to edit_rfc_status_record_path( assigns( :rfc_status_record ))
  end

  test 'should show rfc_status_record' do
    get :show, id: @rfc_status_record
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @rfc_status_record
    assert_response :success
  end

  test 'should update rfc_status_record' do
    patch :update, id: @rfc_status_record, rfc_status_record: { 
      answering_group_id: @rfc_status_record.answering_group_id, 
      answering_group_doc_id: @rfc_status_record.answering_group_doc_id, 
      asking_group_id: @rfc_status_record.asking_group_id, 
      asking_group_doc_id: @rfc_status_record.asking_group_doc_id, 
      current_status: @rfc_status_record.current_status, 
      current_task: @rfc_status_record.current_task, 
      project_doc_id: @rfc_status_record.project_doc_id, 
      rfc_type: @rfc_status_record.rfc_type },
      next_status_task: 0
    assert assigns( :rfc_document )
    assert_redirected_to rfc_status_record_path( assigns( :rfc_status_record ))
  end

  test 'should update rfc_document' do
    assert_not rfc_documents( :one ).initial_version?
    assert_difference( 'RfcDocument.count', +1 ) do
      patch :update, id: @rfc_status_record, rfc_status_record: {
        rfc_document: { question: 'new question' }},
        next_status_task: 0
      assert assigns( :rfc_document )
    end
    assert_redirected_to rfc_status_record_path( assigns( :rfc_status_record ))
  end

  test 'should destroy rfc_status_record' do
    assert_difference('RfcStatusRecord.count', -1) do
      delete :destroy, id: @rfc_status_record
    end
    assert_redirected_to rfc_status_records_path
  end

end
