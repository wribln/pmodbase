require 'test_helper'
class AddressesControllerTest < ActionController::TestCase
  
  setup do
    @address = addresses(:address_one)
    session[ :current_user_id ] = accounts(:account_one).id
  end

  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_ADDRESSES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :addresses )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create address' do
    assert_difference( 'Address.count' ) do
      post :create, address: { label: ( @address.label + @address.id.to_s ), postal_address: @address.postal_address, street_address: @address.street_address }
    end
    assert_redirected_to address_path( assigns( :address ))
  end

  test 'should show address' do
    get :show, id: @address
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @address
    assert_response :success
  end

  test 'should update address' do
    patch :update, id: @address, address: { postal_address: @address.postal_address, street_address: @address.street_address }
    assert_redirected_to address_path( assigns( :address ))
  end

  test 'should destroy address' do
    assert_difference('Address.count', -1) do
      delete :destroy, id: @address
    end
    assert_redirected_to addresses_path
  end
end
