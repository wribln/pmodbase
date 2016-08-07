require 'test_helper'
class CfrLocationTest < ActiveSupport::TestCase

  test 'fixture' do
    l = cfr_locations( :one )
    assert_equal l.cfr_record, cfr_records( :two )
    assert_equal l.cfr_location_type, cfr_location_types( :one )
    assert l.is_main_location
    refute_nil l.file_name
    refute_nil l.doc_version
    refute_nil l.doc_code
    refute_nil l.uri
  end

  test 'try new with defaults' do
    l = CfrLocation.new
    assert_nil l.cfr_record_id
    assert_nil l.cfr_location_type_id
    assert_nil l.file_name
    assert_nil l.doc_version
    assert_nil l.doc_code
    assert_nil l.uri
    refute l.is_main_location
    refute l.valid?
    assert_includes l.errors, :cfr_record
    l.cfr_record_id = cfr_records( :two ).id 
    assert l.valid?
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

  test 'bad file_type error' do
    l = cfr_locations( :one )
    l.cfr_location_type_id = 0
    refute l.valid?
    assert_includes l.errors, :cfr_location_type_id
  end

  test 'bad cfr_record error' do
    l = cfr_locations( :one )
    l.cfr_record_id = 0
    refute l.valid?
    assert_includes l.errors, :cfr_record
  end

  test 'get hyperlink' do
    l = cfr_locations( :one )
    l.uri = nil
    assert_nil l.get_hyperlink
    l.uri = 'C:\temp\test.doc'
    assert_equal 'file://C:\temp\test.doc', l.get_hyperlink
    l.uri = '/home/wr/test.txt'
    assert_equal 'file:///home/wr/test.txt', l.get_hyperlink
    l.uri = 'ftp:///home/wr/test.txt'
    assert_equal l.uri, l.get_hyperlink
    l.uri = 'http://www.workspace.siemens.com/content/00000169/s/Forms/AllItems.asp'
    assert_equal l.uri, l.get_hyperlink
    l.uri = 'https://www.workspace.siemens.com/content/00000169/s/Forms/AllItems.asp'
    assert_equal l.uri, l.get_hyperlink
  end

end
