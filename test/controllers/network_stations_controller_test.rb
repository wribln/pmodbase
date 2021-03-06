require 'test_helper'
class NetworkStationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @network_station = network_stations( :one )
    signon_by_user accounts( :one )
  end

  test 'check class attributes' do
    get network_stations_path
    validate_feature_class_attributes FEATURE_ID_NW_STATIONS, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get network_stations_path
    assert_response :success
    assert_not_nil assigns( :network_stations )
  end

  test 'should get new' do
    get new_network_station_path
    assert_response :success
  end

  test 'should create network_station' do
    assert_difference( 'NetworkStation.count' ) do
      post network_stations_path( params:{ network_station: { 
        code:       @network_station.code + '1', 
        curr_name:  @network_station.curr_name, 
        note:       @network_station.note, 
        prev_name:  @network_station.prev_name, 
        transfer:   @network_station.transfer }})
    end
    assert_redirected_to network_station_path( assigns( :network_station ))
  end

  test 'should show network_station' do
    get network_station_path( id: @network_station )
    assert_response :success
  end

  test 'should get edit' do
    get edit_network_station_path( id: @network_station )
    assert_response :success
  end

  test 'should update network_station: note not empty' do
    patch network_station_path( id: @network_station, params:{ network_station: { code: @network_station.code, transfer: @network_station.transfer, note: 'a test note' }})
    assert_redirected_to network_station_path( assigns( :network_station ))
  end

  test 'should update network_station: note empty' do
    patch network_station_path( id: @network_station, params:{ network_station: { code: @network_station.code, transfer: @network_station.transfer, note: '' }})
    assert_redirected_to network_station_path( assigns( :network_station ))
  end

  test 'should update network_station: note nil' do
    patch network_station_path( id: @network_station, params:{ network_station: { code: @network_station.code, transfer: @network_station.transfer, note: nil }})
    assert_redirected_to network_station_path( assigns( :network_station ))
  end

  test 'should destroy network_station' do
    assert_difference('NetworkStation.count', -1) do
      delete network_station_path( id: @network_station )
    end
    assert_redirected_to network_stations_path
  end

end
