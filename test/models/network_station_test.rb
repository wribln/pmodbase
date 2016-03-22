require 'test_helper'

class NetworkStationTest < ActiveSupport::TestCase

  test 'fixture 1' do
    nst = network_stations( :one )
    assert nst.valid?
    assert nst.transfer
    assert nst.note.blank?
    assert_equal nst.network_stops.count, 2
  end

  test 'fixture 2' do
    nst = network_stations( :two )
    assert nst.valid?
    refute nst.transfer
    refute nst.note.blank?
    assert_equal nst.network_stops.count, 1
  end

  test 'defaults' do
    nst = NetworkStation.new 
    refute nst.valid?
    assert_includes nst.errors, :code, 'error for missing code expected'
    nst.code = 'NEWSTN'
    assert nst.valid?
    assert_equal false, nst.transfer
    assert nst.alt_code.blank?
    assert nst.curr_name.blank?
    assert nst.prev_name.blank?
    assert nst.note.blank?
  end

  test 'must not clear transfer when two stops assigned' do
    nst = network_stations( :one )
    nst.transfer = false
    refute nst.valid?
    assert_includes nst.errors, :transfer
  end

  test 'must not add more than one stop if not transfer station' do
    nst = network_stations( :two )
    ntp1 = nst.network_stops.build
    ntp1.network_line_id = network_lines( :two ).id
    ntp1.stop_no = 2
    refute nst.valid?, 'non-transfer station has already one stop'

  end

  test 'two stops for single station on same line' do
  end

end
