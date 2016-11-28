require 'test_helper'
class RfcStatusRecordTest < ActiveSupport::TestCase

  test 'fixture usefulness' do 
    rsr = rfc_status_records( :rfc_one )
    assert_equal 0, rsr.rfc_type
    assert_nil rsr.asking_group_id
    assert_nil rsr.answering_group_id
    assert rsr.title.blank?
    assert rsr.project_doc_id.blank?
    assert rsr.project_rms_id.blank?
    assert rsr.asking_group_doc_id.blank?
    assert rsr.answering_group_doc_id.blank?
    assert_equal 0, rsr.current_status
    assert_equal 1, rsr.current_task
    assert rsr.valid?
  end

  test 'defaults' do 
    rsr = RfcStatusRecord.new
    assert_nil rsr.id
    assert 0, rsr.rfc_type
    assert_nil rsr.title
    assert_nil rsr.asking_group_id
    assert_nil rsr.answering_group_id
    assert_nil rsr.project_doc_id
    assert_nil rsr.project_rms_id
    assert_nil rsr.asking_group_doc_id
    assert_nil rsr.answering_group_doc_id
    assert_equal 0, rsr.current_status
    assert_equal 0, rsr.current_task
    assert rsr.valid?
  end

  test 'group codes and labels' do 
    rsr = rfc_status_records( :rfc_one )
    assert '', rsr.group_code( :asking_group )
    assert '', rsr.group_code( :answering_group )
    assert '', rsr.group_code_and_label( :asking_group )
    assert '', rsr.group_code_and_label( :answering_group )
    g1 = groups( :group_one )
    g2 = groups( :group_two )
    rsr.asking_group_id = g1.id
    rsr.answering_group_id = g2.id
    assert rsr.valid?
    assert_equal g1.code, rsr.group_code( :asking_group )
    assert_equal g2.code, rsr.group_code( :answering_group )
    assert_equal g1.code_and_label, rsr.group_code_and_label( :asking_group )
    assert_equal g2.code_and_label, rsr.group_code_and_label( :answering_group )
    rsr.asking_group_id = nil 
    assert '', rsr.group_code( :asking_group )
    assert '', rsr.group_code_and_label( :asking_group )
    assert rsr.valid?
    rsr.answering_group_id = nil
    assert '', rsr.group_code( :answering_group )
    assert '', rsr.group_code_and_label( :answering_group )
    assert rsr.valid?
    assert rsr.save
  end

end
