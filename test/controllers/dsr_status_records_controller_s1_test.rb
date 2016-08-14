require 'test_helper'
class DsrStatusRecordsControllerS1Test < ActionController::TestCase
  tests DsrStatusRecordsController

  # Test Statistics

  setup do
    # set maximum permission
    @account = accounts( :one )
    pg = @account.permission4_groups.where( feature_id: FEATURE_ID_DSR_STATUS_RECORDS )
    pg[ 0 ].to_read = 4
    pg[ 0 ].to_update = 4
    pg[ 0 ].to_create = 4
    pg[ 0 ].save
    session[ :current_user_id ] = accounts( :one ).id
    #@dsr_status_record = dsr_status_records( :dsr_rec_one )
  end

  test 'should get stats index page' do
    assert @account.permission_for_task?( FEATURE_ID_DSR_STATUS_RECORDS, 0, 0 )
    assert_equal [ 0 ],@account.permitted_workflows( FEATURE_ID_DSR_STATUS_RECORDS )
    get :stats
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  for i in 1..16
    test "should get stats type #{i}" do
      get :stats, document_status: i
      assert_response :success
    end
  end

  test 'stats on empty database' do
    assert_difference( 'DsrStatusRecord.count', -2 ) do
      DsrStatusRecord.destroy_all
    end
    for i in 1..16
      get :stats, id: i
      assert_response :success
    end
  end

  test 'should get stats type bad' do
    get :stats, id: 17
    assert_response :success
  end

end
