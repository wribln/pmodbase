require 'test_helper'
class NetworkStopsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @network_stop = network_stops( :one )
    signon_by_user accounts( :one )
  end

  test 'check class attributes' do
    get network_stops_path
    validate_feature_class_attributes FEATURE_ID_NW_STOPS, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get network_stops_path
    assert_response :success
    assert_not_nil assigns( :network_stops )
  end

  test 'should get new' do
    get new_network_stop_path
    assert_response :success
  end

  test 'should create network_stop' do
    assert_difference( 'NetworkStop.count' ) do
      post network_stops_path( params:{ network_stop: {
        network_station_id: @network_stop.network_station_id,
        network_line_id:    @network_stop.network_line_id,
        stop_no: 2,
        location_code_id:   @network_stop.location_code_id }})
    end
    assert_redirected_to network_stop_path( assigns( :network_stop ))
  end

  test 'should show network_stop' do
    get network_stop_path( id: @network_stop )
    assert_response :success
  end

  test 'should get edit' do
    get edit_network_stop_path( id: @network_stop )
    assert_response :success
  end

  test 'should update network_stop' do
    patch network_stop_path( id: @network_stop, params:{ network_stop: {
        network_station_id: @network_stop.network_station_id,
        network_line_id:    @network_stop.network_line_id,
        stop_no: 2,
        location_code_id:   @network_stop.location_code_id }})
    assert_redirected_to network_stop_path(assigns( :network_stop ))
  end

  test 'should destroy network_stop' do
    assert_difference('NetworkStop.count', -1) do
      delete network_stop_path( id: @network_stop )
    end
    assert_redirected_to network_stops_path
  end
end
