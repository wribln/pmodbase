require 'test_helper'
class CsrStatusRecordsControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
    @csr_status_record = csr_status_records( :csr_one )
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:csr_status_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create csr_status_record" do
    assert_difference('CsrStatusRecord.count') do
      post :create, csr_status_record: { 
        actual_reply_date: @csr_status_record.actual_reply_date,
        classification: @csr_status_record.classification, 
        correspondence_date: @csr_status_record.correspondence_date,
        correspondence_type: @csr_status_record.correspondence_type, 
        notes: @csr_status_record.notes,
        sender_doc_id: @csr_status_record.sender_doc_id,
#        sender_group_id: @csr_status_record.sender_group_id,
#        sender_reference: @csr_status_record.sender_reference,
#        receiver_group_id: @csr_status_record.receiver_group_id,
#        plan_reply_date: @csr_status_record.plan_reply_date,
#        project_doc_id: @csr_status_record.project_doc_id,
#        status: @csr_status_record.status,
#        subject: @csr_status_record.subject,
#        reply_status_record_id: @csr_status_record.reply_status_record_id,
        transmission_type: @csr_status_record.transmission_type }
    end
    assert_redirected_to csr_status_record_path( assigns( :csr_status_record ))
  end

  test "should show csr_status_record" do
    get :show, id: @csr_status_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @csr_status_record
    assert_response :success
  end

  test "should update csr_status_record" do
    patch :update, id: @csr_status_record, csr_status_record: {
        actual_reply_date: @csr_status_record.actual_reply_date,
        classification: @csr_status_record.classification, 
        correspondence_date: @csr_status_record.correspondence_date,
        correspondence_type: @csr_status_record.correspondence_type, 
        notes: @csr_status_record.notes,
        sender_doc_id: @csr_status_record.sender_doc_id,
        sender_group_id: @csr_status_record.sender_group_id,
        sender_reference: @csr_status_record.sender_reference,
        receiver_group_id: @csr_status_record.receiver_group_id,
        plan_reply_date: @csr_status_record.plan_reply_date,
        project_doc_id: @csr_status_record.project_doc_id,
        status: @csr_status_record.status,
        subject: @csr_status_record.subject,
        reply_status_record_id: @csr_status_record.reply_status_record_id,
        transmission_type: @csr_status_record.transmission_type }
    assert_redirected_to csr_status_record_path( assigns( :csr_status_record ))
  end

  test "should destroy csr_status_record" do
    assert_difference('CsrStatusRecord.count', -1) do
      delete :destroy, id: @csr_status_record
    end

    assert_redirected_to csr_status_records_path
  end
end
