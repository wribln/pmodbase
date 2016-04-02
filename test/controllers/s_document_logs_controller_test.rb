require 'test_helper'
class SDocumentLogsControllerTest < ActionController::TestCase

  setup do
    @s_document_log = s_document_logs( :one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :s_document_logs )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create s_document_log" do
    assert_difference( 'SDocumentLog.count' ) do
      post :create, s_document_log: { group_id: @s_document_log.group_id, author_date: @s_document_log.author_date, dcc_code: @s_document_log.dcc_code, function_code: @s_document_log.function_code, title: @s_document_log.title }
    end
    assert_redirected_to s_document_log_path( assigns( :s_document_log ))
  end

  test "should show s_document_log" do
    get :show, id: @s_document_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @s_document_log
    assert_response :success
  end

  test "should update s_document_log" do
    patch :update, id: @s_document_log, s_document_log: { author_date: @s_document_log.author_date, dcc_code: @s_document_log.dcc_code, function_code: @s_document_log.function_code, location_code: @s_document_log.location_code, phase_code: @s_document_log.phase_code, product_code: @s_document_log.product_code, receiver_group: @s_document_log.receiver_group, revision_code: @s_document_log.revision_code, service_code: @s_document_log.service_code, title: @s_document_log.title }
    assert_redirected_to s_document_log_path( assigns( :s_document_log ))
  end

  test "should destroy s_document_log" do
    assert_difference('SDocumentLog.count', -1) do
      delete :destroy, id: @s_document_log
    end
    assert_redirected_to s_document_logs_path
  end

end