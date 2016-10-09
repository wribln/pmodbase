require 'test_helper'
class CfrRecordsController3Test < ActionController::TestCase
  tests CfrRecordsController

  # tests with frozen record

  setup do
    @cfr_record = cfr_records( :one )
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'should update cfr_record' do
    patch :update, id: @cfr_record, cfr_record: { 
      title: 'test 1 2 3', rec_frozen: true }
    r = assigns( :cfr_record )
    assert_redirected_to cfr_record_details_path( r )
    assert_empty r.errors

    r.save
    @cfr_record.reload

    patch :update, id: @cfr_record, cfr_record: {
      title: 'test 4 5 6' }
    r = assigns( :cfr_record )
    assert_redirected_to cfr_record_details_path( @cfr_record )

    assert_no_difference( 'CfrRecord.count' ) do
      delete :destroy, id: @cfr_record
    end
    r = assigns( :cfr_record )
    assert_redirected_to cfr_record_details_path( @cfr_record )
    refute_empty flash
  end

end
