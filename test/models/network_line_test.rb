require 'test_helper'
class NetworkLineTest < ActiveSupport::TestCase

  test 'fixture' do
    nwl = network_lines( :one )
    assert_equal 'L1',nwl.code
    assert_equal location_codes( :three ).id, nwl.location_code_id
    assert_equal 1,nwl.seqno
    refute_nil nwl.note
  end

  test 'defaults' do
    nwl = NetworkLine.new 
    refute nwl.valid?
    assert_includes nwl.errors, :code, 'error for missiong code expected'
    assert_includes nwl.errors, :label, 'error for missing label expected'
    nwl.code = 'TEST'
    refute nwl.valid?
    assert_includes nwl.errors, :label, 'error for missing label expected'
    nwl.label = 'Test Label'
    assert nwl.valid?
    assert_equal 0, nwl.seqno
    nwl.seqno = nil
    refute nwl.valid?
    assert_includes nwl.errors, :seqno, 'seqno must be specified'
  end

  test 'given location code must exist' do
    nwl = network_lines( :one )
    assert nwl.valid?
    nwl.location_code_id = nil
    assert nwl.valid?
    nwl.location_code_id = 0
    refute nwl.valid?
    assert_includes nwl.errors, :location_code_id, 'location code does not exist'
  end

end
