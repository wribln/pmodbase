require 'test_helper'
class RfcDocumentTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    rd = rfc_documents( :one )
    assert_equal rfc_status_records( :rfc_one ).id,rd.rfc_status_record_id
    assert_equal 0,rd.version
    assert_equal accounts( :account_wop ).id,rd.account_id
  end

  test "all required parameters" do
    rda = RfcDocument.new
    rdb = rfc_documents( :one )
    rda.rfc_status_record_id = rdb.rfc_status_record_id
    assert_not rda.valid?
    rda.account_id = rdb.account_id
    assert rda.valid?
  end

  test "default values" do
    rd = RfcDocument.new
    assert_equal 0,rd.version
  end

  test "modified" do
    rd1 = rfc_documents( :one )
    rd2 = rd1.dup
    assert_not rd2.modified?( rd1 )
    rd2.version += 1
    assert_not rd2.modified?( rd1 )

    rd2.answer = "an answer"
    assert_not_equal rd1.answer, rd2.answer
    assert rd2.modified?( rd1 )
    rd2.answer = rd1.answer
    assert_not rd2.modified?( rd1 )

    rd2.question = "a question"
    assert_not_equal rd1.question, rd2.question
    assert rd2.modified?( rd1 )
    rd2.question = rd1.question
    assert_not rd2.modified?( rd1 )

    rd2.note = "a note"
    assert_not_equal rd1.note, rd2.note
    assert rd2.modified?( rd1 )
    rd2.note = rd1.note
    assert_not rd2.modified?( rd1 )
  end

end
