require 'test_helper'
class NetworkStopTest < ActiveSupport::TestCase

  test 'fixture 1' do 
    nst = network_stops( :one )
    assert nst.valid?
    assert nst.network_line.id = network_lines( :one ).id
    assert nst.network_station.id = network_stations( :one ).id
    assert_equal 'L1S1', nst.code
    assert_equal 1, nst.stop_no
    assert nst.location_code.id = location_codes( :two ).id
  end

  test 'fixture 2' do 
    nst = network_stops( :two )
    assert nst.valid?
    assert nst.network_line.id = network_lines( :two ).id
    assert nst.network_station.id = network_stations( :one ).id
    assert_equal 'L2S1', nst.code
    assert_equal 2, nst.stop_no
    assert nst.location_code.id = location_codes( :one ).id
  end

  test 'fixture 3' do 
    nst = network_stops( :three )
    assert nst.valid?
    assert nst.network_line.id = network_lines( :two ).id
    assert nst.network_station.id = network_stations( :two ).id
    assert_equal 'L2S2', nst.code
    assert_equal 1, nst.stop_no
    assert_nil nst.location_code
  end

  test 'required fields' do
    nst = NetworkStop.new 
    refute nst.valid?
    assert_includes nst.errors, :stop_no
    assert_includes nst.errors, :network_line_id
    assert_includes nst.errors, :network_station_id
    nst.network_line = network_lines( :one )
    refute nst.valid?
    assert_includes nst.errors, :stop_no
    refute_includes nst.errors, :network_line_id
    assert_includes nst.errors, :network_station_id
    nst.stop_no = 2
    refute nst.valid?
    refute_includes nst.errors, :stop_no
    refute_includes nst.errors, :network_line_id
    assert_includes nst.errors, :network_station_id
    nst.network_station = network_stations( :one )
    assert nst.valid?
  end

  test 'line must exist' do
    nst = NetworkStop.new
    nst.network_station = network_stations( :one )
    nst.network_line_id = 0
    nst.stop_no = 0
    refute nst.valid?
    assert_includes nst.errors, :network_line_id
    nst.network_line = network_lines( :two )
    assert nst.valid?
  end

  test 'station must exist' do
    nst = NetworkStop.new
    nst.network_line = network_lines( :two )
    nst.stop_no = 0
    refute nst.valid?
    assert_includes nst.errors, :network_station_id
    nst.network_station = network_stations( :one )
    assert nst.valid?
  end

end
