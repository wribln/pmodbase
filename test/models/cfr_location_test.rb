require 'test_helper'
class CfrLocationTest < ActiveSupport::TestCase

  test 'fixture' do
    l = cfr_locations( :one )
    assert_equal l.cfr_record, cfr_records( :two )
    assert_equal l.cfr_location_type, cfr_location_types( :one )
    refute_nil l.file_name
    refute_nil l.doc_version
    refute_nil l.doc_code
    refute_nil l.uri
  end

  test 'set defaults' do
    l = cfr_locations( :one )
    l.file_name = nil
    l.set_defaults
    assert_equal 'high.pdf', l.file_name

    l.uri = ''
    l.file_name = nil
    l.set_defaults
    assert_nil l.file_name

    l.uri = 'c:\test\test.pdf'
    l.cfr_location_type = nil
    l.file_name = nil
    l.set_defaults
    assert_nil l.file_name
  end

end
