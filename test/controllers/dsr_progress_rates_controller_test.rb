require 'test_helper'
class DsrProgressRatesControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
    @dsr_progress_rate = dsr_progress_rates( :p00 )
  end

  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_DSR_PROGRESS_RATES, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :dsr_progress_rates )
  end

  test "should show dsr_progress_rate" do
    get :show, id: @dsr_progress_rate
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dsr_progress_rate
    assert_response :success
  end

  test "should update dsr_progress_rate" do
    patch :update, id: @dsr_progress_rate, dsr_progress_rate: { document_progress: @dsr_progress_rate.document_progress }
    assert_redirected_to dsr_progress_rate_path(assigns( :dsr_progress_rate ))
  end

end
