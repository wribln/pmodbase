require 'test_helper'
class DsrSubmissionTest < ActiveSupport::TestCase

  test 'fixture 1' do
    s = dsr_submissions( :dsr_sub_one )
    assert_equal 1,s.submission_no
    assert_equal dsr_status_records( :dsr_rec_two ).id, s.dsr_status_record_id
    assert s.valid?    
  end

  test 'fixture 2' do
    s = dsr_submissions( :dsr_sub_two )
    assert_equal 2,s.submission_no
    assert_equal dsr_status_records( :dsr_rec_two ).id, s.dsr_status_record_id
    assert s.valid?    
  end

  test 'defaults' do
    s = DsrSubmission.new
    assert_nil s.dsr_status_record_id
    assert_equal 1,s.submission_no
    assert_nil s.receiver_doc_id_version
    assert_nil s.project_doc_id_version
    assert_nil s.submission_receiver_doc_id
    assert_nil s.submission_project_doc_id
    assert_nil s.response_sender_doc_id
    assert_nil s.response_project_doc_id
    assert_nil s.plnd_submission
    assert_nil s.actl_submission
    assert_nil s.xpcd_response
    assert_nil s.actl_response
    assert_nil s.response_status
  end

  test 'minimum validations' do
    s = DsrSubmission.new
    refute s.valid?
    s.dsr_status_record_id = dsr_status_records( :dsr_rec_one ).id
    assert s.valid?
  end

  test 'related dsr record must exist' do
    s = dsr_submissions( :dsr_sub_one )
    assert s.valid?
    s.dsr_status_record_id = nil 
    refute s.valid?
    assert_includes s.errors, :dsr_status_record_id
    s.dsr_status_record_id = 0
    refute s.valid?
    assert_includes s.errors, :dsr_status_record_id
  end

  test 'submission no must be unique for a specific dsr record' do
    s = dsr_submissions( :dsr_sub_two ).dup
    refute s.valid?
    s.submission_no += 1
    assert s.valid?
  end

end
