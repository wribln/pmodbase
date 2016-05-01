require 'test_helper'
class CsrStatusRecordTest < ActiveSupport::TestCase

  test "fixture 1 usefulness" do 
    csr = csr_status_records( :csr_one )
    assert_equal 1, csr.correspondence_type
    assert_equal 1, csr.transmission_type
    assert_not_empty csr.subject
    assert_equal groups( :group_one ).id, csr.sender_group_id
    assert_equal groups( :group_two ).id, csr.receiver_group_id
    assert_nil csr.reply_status_record_id
    assert csr.valid?
  end

  test "fixture 2 usefulness" do 
    csr = csr_status_records( :csr_two )
    assert_equal 0, csr.correspondence_type
    assert_equal 1, csr.transmission_type
    assert_equal groups( :group_one ).id, csr.sender_group_id
    assert_equal groups( :group_two ).id, csr.receiver_group_id
    assert_equal csr_status_records( :csr_one ).id, csr.reply_status_record_id
    assert csr.valid?
  end

  test 'incoming/outgoing' do
    csr = CsrStatusRecord.new
    csr.correspondence_type = 0
    assert csr.incoming?
    assert_not csr.outgoing?
    assert_equal I18n.t( 'activerecord.attributes.csr_status_record.correspondence_types' )[ 0 ], csr.correspondence_type_label
    csr.correspondence_type = 1
    assert_not csr.incoming?
    assert csr.outgoing?
    assert_equal I18n.t( 'activerecord.attributes.csr_status_record.correspondence_types' )[ 1 ], csr.correspondence_type_label
  end

  test 'defaults' do
    csr = CsrStatusRecord.new
    assert_equal 0, csr.status 
  end

  test 'required attributes' do
    csr = CsrStatusRecord.new
    assert_not csr.valid?
    assert_includes csr.errors, :correspondence_type

    csr.correspondence_type = 0
    assert_not csr.valid?
    assert_includes csr.errors, :correspondence_date

    csr.correspondence_date = Date.today
    assert csr.valid?
  end

  test '_label' do
    csr = CsrStatusRecord.new
    csr.status = nil
    assert_nil csr.correspondence_type_label
    assert_nil csr.classification_label
    assert_nil csr.status_label
  end

  test 'validity of reply_status_record_id' do
    csr1 = CsrStatusRecord.new
    csr2 = csr_status_records( :csr_one )
    csr1.correspondence_type = csr2.correspondence_type
    csr1.correspondence_date = Date.today

    assert csr1.valid?
    assert csr2.valid?

    csr1.reply_status_record_id = 0
    assert_not csr1.valid?
    assert_includes csr1.errors, :reply_status_record_id

    csr1.reply_status_record_id = csr2.id
    csr1.id = csr2.id
    assert_not csr1.valid?
    assert_includes csr1.errors, :reply_status_record_id

    csr1.id = 0
    assert_not csr1.valid?
    assert_includes csr1.errors, :reply_status_record_id

    csr1.correspondence_type = ( csr2.correspondence_type + 1 ) % 2 
    assert csr1.valid?
  end

  test 'group codes' do
    csr = csr_status_records( :csr_one )
    assert_equal groups( :group_one ).id, csr.sender_group_id
    assert_equal groups( :group_two ).id, csr.receiver_group_id
    assert_equal 1, csr.correspondence_type

    assert_equal groups( :group_one ).code, csr.sender_group_code
    assert_equal groups( :group_two ).code, csr.receiver_group_code

    assert csr.outgoing?
    assert_equal csr.receiver_group_code, csr.sender_receiver_group_code

    csr.correspondence_type = 0
    assert csr.incoming?
    assert_equal csr.sender_group_code, csr.sender_receiver_group_code

    csr.sender_group_id = 0
    assert_equal "[0]",csr.sender_group_code

    csr.sender_group_id = nil
    assert_equal "",csr.sender_group_code

    csr.receiver_group_id = 0
    assert_equal "[0]",csr.receiver_group_code

    csr.receiver_group_id = nil
    assert_equal "",csr.receiver_group_code

  end

  test 'all scopes' do
    as = CsrStatusRecord.ff_id( csr_status_records( :csr_one ).id )
    assert_equal 1, as.length

    as = CsrStatusRecord.ff_id( 0 )
    assert_equal 0, as.length

    as = CsrStatusRecord.ff_type( 0 )
    assert_equal 1, as.length

    as = CsrStatusRecord.ff_type( 1 )
    assert_equal 1, as.length

    as = CsrStatusRecord.ff_type( 2 )
    assert_equal 0, as.length

    as = CsrStatusRecord.ff_group( groups( :group_one ).id )
    assert_equal 2, as.length

    as = CsrStatusRecord.ff_group( groups( :group_two ).id )
    assert_equal 2, as.length

    as = CsrStatusRecord.ff_group( 0 )
    assert_equal 0, as.length

    as = CsrStatusRecord.ff_class( 1 )
    assert_equal 2, as.length

    as = CsrStatusRecord.ff_class( 0 )
    assert_equal 0, as.length

    as = CsrStatusRecord.ff_status( 1 )
    assert_equal 2, as.length

    as = CsrStatusRecord.ff_status( 0 )
    assert_equal 0, as.length

    as = CsrStatusRecord.ff_subj( 'Test' )
    assert_equal 2, as.length

    as = CsrStatusRecord.ff_subj( 'foobar' )
    assert_equal 0, as.length

    as = CsrStatusRecord.ff_note( 'note' )
    assert_equal 2, as.length

    as = CsrStatusRecord.ff_note( 'foobar' )
    assert_equal 0, as.length

  end

end
