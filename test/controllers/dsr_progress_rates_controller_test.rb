require 'test_helper'
class DsrProgressRatesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @account = accounts( :one )
    signon_by_user @account
    @dsr_progress_rate = dsr_progress_rates( :p00 )
  end

  test 'check class_attributes'  do
    get dsr_progress_rates_path
    validate_feature_class_attributes FEATURE_ID_DSR_PROGRESS_RATES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get dsr_progress_rates_path
    assert_response :success
    assert_not_nil assigns( :dsr_progress_rates )
  end

  test 'should show dsr_progress_rate' do
    get dsr_progress_rate_path( id: @dsr_progress_rate )
    assert_response :success
  end

  test 'should get edit' do
    get edit_dsr_progress_rate_path( id: @dsr_progress_rate )
    assert_response :success
  end

  test 'should update dsr_progress_rate' do
    patch dsr_progress_rate_path( id: @dsr_progress_rate, params:{ dsr_progress_rate: { document_progress: @dsr_progress_rate.document_progress }})
    assert_redirected_to dsr_progress_rate_path(assigns( :dsr_progress_rate ))
  end

end
