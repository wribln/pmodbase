require 'test_helper'
class AddressesControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    signon_by_user accounts( :one )
    @address = addresses( :address_one )
  end

  test 'check class_attributes'  do
    get addresses_path
    validate_feature_class_attributes FEATURE_ID_ADDRESSES, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get addresses_path
    assert_response :success
    assert_not_nil assigns( :addresses )
  end

  test 'should get new' do
    get new_address_path
    assert_response :success
  end

  test 'should create address' do
    assert_difference( 'Address.count' ) do
      post addresses_path, params:{ address: { label: ( @address.label + @address.id.to_s ), postal_address: @address.postal_address, street_address: @address.street_address }}
    end
    assert_redirected_to address_path( assigns( :address ))
  end

  test 'should show address' do
    get address_path( id: @address )
    assert_response :success
  end

  test 'should get edit' do
    get edit_address_path( id: @address )
    assert_response :success
  end

  test 'should update address' do
    patch address_path( id: @address, params:{ address: { postal_address: @address.postal_address, street_address: @address.street_address }})
    assert_redirected_to address_path( assigns( :address ))
  end

  test 'should destroy address' do
    assert_difference('Address.count', -1) do
      delete address_path( id: @address )
    end
    assert_redirected_to addresses_path
  end
end
