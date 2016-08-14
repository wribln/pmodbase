require 'test_helper'
class DsrStatusRecordsController5Test < ActionController::TestCase
  tests DsrStatusRecordsController

  # perform all workflow tasks - standard sequence, access level 1

  setup do
    # set maximum permission
    @account = accounts( :one )
    pg = @account.permission4_groups.where( feature_id: FEATURE_ID_DSR_STATUS_RECORDS )
    pg[ 0 ].to_read = 1
    pg[ 0 ].to_update = 1
    pg[ 0 ].to_create = 1
    pg[ 0 ].save
    session[ :current_user_id ] = accounts( :one ).id
    @dsr_status_record = dsr_status_records( :dsr_rec_one )
  end

  test 'should get new' do
    assert @account.permission_for_task?( FEATURE_ID_DSR_STATUS_RECORDS, 0, 0 )
    assert_equal [ 0 ],@account.permitted_workflows( FEATURE_ID_DSR_STATUS_RECORDS )
    get :new
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should show dsr entry' do
    get :show, id: @dsr_status_record
    assert_response :success
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
  end

  test 'should create dsr_status_record' do
    assert_difference( 'DsrStatusRecord.count' ) do
      post :create, dsr_status_record: {
        title:           @dsr_status_record.title,
        sender_group_id: @dsr_status_record.sender_group_id }
    end
    new_dsr = assigns( :dsr_status_record )
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 0, assigns( :dsr_status_record ).current_status
    assert_equal 1, assigns( :dsr_status_record ).current_task
    assert_equal 0, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 1 
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_nil assigns( :dsr_previous_record )
    assert_nil assigns( :dsr_show_add_checkbox )
    assert_equal 1, assigns( :dsr_status_record ).current_status
    assert_equal 2, assigns( :dsr_status_record ).current_task
    assert_equal 0, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 1
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 2, assigns( :dsr_status_record ).current_status
    assert_equal 3, assigns( :dsr_status_record ).current_task
    assert_equal 0, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 1
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 3, assigns( :dsr_status_record ).current_status
    assert_equal 3, assigns( :dsr_status_record ).current_task
    assert_equal 1, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 2
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 4, assigns( :dsr_status_record ).current_status
    assert_equal 4, assigns( :dsr_status_record ).current_task
    assert_equal 1, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 2
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 5, assigns( :dsr_status_record ).current_status
    assert_equal 5, assigns( :dsr_status_record ).current_task
    assert_equal 2, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 2
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 6, assigns( :dsr_status_record ).current_status
    assert_equal 6, assigns( :dsr_status_record ).current_task
    assert_equal 3, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 2
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 8, assigns( :dsr_status_record ).current_status
    assert_equal 7, assigns( :dsr_status_record ).current_task
    assert_equal 4, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 1
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 9, assigns( :dsr_status_record ).current_status
    assert_equal 8, assigns( :dsr_status_record ).current_task
    assert_equal 4, assigns( :dsr_status_record ).document_status

    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      next_status_task: 3
    assert_response :success # eror message: response status incorrect
    patch :update, id: new_dsr.id,
      dsr_status_record: { title: @dsr_status_record.title },
      dsr_submission: { response_status: 0 }, # A - approved#
      next_status_task: 3
    assert_redirected_to dsr_status_record_path( assigns( :dsr_status_record ))
    assert_equal 13, assigns( :dsr_status_record ).current_status
    assert_equal 10, assigns( :dsr_status_record ).current_task
    assert_equal 5, assigns( :dsr_status_record ).document_status
  end

end
