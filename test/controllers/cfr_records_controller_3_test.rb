require 'test_helper'
class CfrRecordsController3Test < ActionDispatch::IntegrationTest

  # tests with frozen record

  setup do
    @cfr_record = cfr_records( :one )
    @account = accounts( :one )
    signon_by_user @account
  end

  test 'should update cfr_record' do
    patch cfr_record_path( id: @cfr_record, params:{ cfr_record:{ 
      title: 'test 1 2 3', rec_frozen: true }})
    r = assigns( :cfr_record )
    assert_redirected_to cfr_record_path( @cfr_record )
    assert_empty r.errors
    r.save
    @cfr_record.reload

    patch cfr_record_path( id: @cfr_record, params:{ cfr_record: {
      title: 'test 4 5 6' }})
    assert assigns( :cfr_record )
    assert_redirected_to cfr_record_details_path( @cfr_record )
    assert_no_difference( 'CfrRecord.count' ) do
      delete cfr_record_path( id: @cfr_record )
    end
    assert assigns( :cfr_record )
    assert_redirected_to cfr_record_details_path( @cfr_record )
    refute_empty flash
  end

end
