require 'test_helper'
class IsrAgreementsControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = @account.id
  end

  test 'check class attributes' do
    validate_feature_class_attributes FEATURE_ID_ISR_AGREEMENTS, 
      ApplicationController::FEATURE_ACCESS_READ,
      ApplicationController::FEATURE_CONTROL_NONE, 0
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :isr_agreements )
  end

end
