require 'test_helper'
class SDocumentLogsControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @s_document_log = s_document_logs( :one )
  end

  test 'check class_attributes'  do
    get s_document_logs_path
    validate_feature_class_attributes FEATURE_ID_S_DOCUMENT_LOG, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get s_document_logs_path
    assert_response :success
    assert_not_nil assigns( :s_document_logs )
  end

  test 'should get new' do
    get new_s_document_log_path
    assert_response :success
  end

  test 'should create s_document_log' do
    assert_difference( 'SDocumentLog.count' ) do
      post s_document_logs_path, params:{ s_document_log: { group_id: @s_document_log.group_id, author_date: @s_document_log.author_date, dcc_code: @s_document_log.dcc_code, function_code: @s_document_log.function_code, title: @s_document_log.title }}
    end
    assert_redirected_to s_document_log_path( assigns( :s_document_log ))
  end

  test 'test partial input 0' do
    assert_difference( 'SDocumentLog.count', 0 ) do
      post s_document_logs_path, params:{ s_document_log: { group_id: nil }}
    end
    sdl = assigns( :s_document_log )
    assert_includes sdl.errors, :group_id
    assert_includes sdl.errors, :dcc_code
    assert_includes sdl.errors, :base
    assert_response :success
  end

  test 'test partial input 1' do
    assert_difference( 'SDocumentLog.count', 0 ) do
      post s_document_logs_path, params:{ s_document_log: { group_id: @s_document_log.group_id, dcc_code: @s_document_log.dcc_code }}
    end
    sdl = assigns( :s_document_log )
    assert_includes sdl.errors, :base
    assert_response :success
  end

  test 'test partial input ok w/ function code' do
    assert_difference( 'SDocumentLog.count' ) do
      post s_document_logs_path, params:{ s_document_log: { group_id: @s_document_log.group_id, dcc_code: @s_document_log.dcc_code, function_code: @s_document_log.function_code }}
    end
    assert_redirected_to s_document_log_path( assigns( :s_document_log ))
  end

  test 'test partial input ok w/ product code' do
    assert_difference( 'SDocumentLog.count' ) do
      post s_document_logs_path, params:{ s_document_log: { group_id: @s_document_log.group_id, dcc_code: @s_document_log.dcc_code, product_code: @s_document_log.product_code }}
    end
    assert_redirected_to s_document_log_path( assigns( :s_document_log ))
  end

  test 'test partial input ok w/ service code' do
    assert_difference( 'SDocumentLog.count' ) do
      post s_document_logs_path, params:{ s_document_log: { group_id: @s_document_log.group_id, dcc_code: @s_document_log.dcc_code, service_code: @s_document_log.service_code }}
    end
    assert_redirected_to s_document_log_path( assigns( :s_document_log ))
  end

  test 'test partial input ok w/ phase code' do
    assert_difference( 'SDocumentLog.count' ) do
      post s_document_logs_path, params:{ s_document_log: { group_id: @s_document_log.group_id, dcc_code: @s_document_log.dcc_code, phase_code: @s_document_log.phase_code }}
    end
    assert_redirected_to s_document_log_path( assigns( :s_document_log ))
  end

  test 'should show s_document_log' do
    get s_document_log_path( id: @s_document_log )
    assert_response :success
  end

  test 'should get edit' do
    get edit_s_document_log_path( id: @s_document_log )
    assert_response :success
  end

  test 'should update s_document_log' do
    patch s_document_log_path( id: @s_document_log, params:{ s_document_log: { author_date: @s_document_log.author_date, dcc_code: @s_document_log.dcc_code, function_code: @s_document_log.function_code, location_code: @s_document_log.location_code, phase_code: @s_document_log.phase_code, product_code: @s_document_log.product_code, receiver_group: @s_document_log.receiver_group, revision_code: @s_document_log.revision_code, service_code: @s_document_log.service_code, title: @s_document_log.title }})
    assert_redirected_to s_document_log_path( assigns( :s_document_log ))
  end

  test 'should destroy s_document_log' do
    assert_difference('SDocumentLog.count', -1) do
      delete s_document_log_path( id: @s_document_log )
    end
    assert_redirected_to s_document_logs_path
  end

end
