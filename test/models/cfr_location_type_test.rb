require 'test_helper'
class CfrLocationTypeTest < ActiveSupport::TestCase

  test 'fixture 1' do 
    lt = cfr_location_types( :one )
    refute lt.label.blank?
    refute lt.path_prefix.empty?
    refute lt.concat_char.empty?
    refute lt.note.empty?
    assert lt.project_dms
    assert_equal 0, lt.location_type
    assert lt.valid?, lt.errors.messages
  end

  test 'fixture 2' do 
    lt = cfr_location_types( :two )
    refute lt.label.blank?
    refute lt.path_prefix.empty?
    refute lt.concat_char.empty?
    refute lt.note.empty?
    refute lt.project_dms
    assert_equal 1, lt.location_type
    assert lt.valid?, lt.errors.messages
  end

  test 'fixture 3' do
    lt = cfr_location_types( :three )
    refute lt.label.blank?
    refute lt.path_prefix.empty?
    refute lt.concat_char.empty?
    refute lt.note.empty?
    refute lt.project_dms
    assert_equal 2, lt.location_type
    assert lt.valid?, lt.errors.messages
  end

  test 'defaults' do
    lt = CfrLocationType.new
    assert_nil lt.label
    assert_nil lt.note
    assert_nil lt.path_prefix
    refute lt.project_dms
    assert_equal 0, lt.location_type
    assert_nil lt.concat_char
  end

  test 'only one project_dms' do
    lt = CfrLocationType.new
    lt.label = 'test'
    lt.project_dms = true
    refute lt.valid?
    assert_includes lt.errors, :project_dms
    lt.project_dms = false
    assert lt.valid?
  end

  test 'path prefix must be unique' do
    lt = cfr_location_types( :one ).dup
    lt.project_dms = false
    refute lt.valid?
    assert_includes lt.errors, :path_prefix
    lt.path_prefix = cfr_location_types( :two ).path_prefix
    refute lt.valid?
    assert_includes lt.errors, :path_prefix
    lt.path_prefix = nil 
    assert lt.valid?
  end

  test 'retrieve matching location' do
    assert_nil CfrLocationType.find_location_type( nil )
    assert_nil CfrLocationType.find_location_type( '' )
    assert_nil CfrLocationType.find_location_type( '   ' )
    assert_nil CfrLocationType.find_location_type( 'X:\somewhere\over\the.ext' )
    assert_nil CfrLocationType.find_location_type( 'X:\somewhere\over\the\rainbow' )
    assert_nil CfrLocationType.find_location_type( 'X:\somewhere\over\the\rainbow.ext' )
    assert_nil CfrLocationType.find_location_type( 'X:\Somewhere\over\the\rainbow\file.ext' )
    assert_equal CfrLocationType.find_location_type( 'X:\somewhere\over\the\rainbow\file.ext' ), cfr_location_types( :one )
    assert_equal CfrLocationType.find_location_type( 'x:\somewhere\over\the\rainbow\file.ext' ), cfr_location_types( :one )
    
    assert_nil CfrLocationType.find_location_type( 'http://www.google.com' )
    assert_nil CfrLocationType.find_location_type( 'http://www.google.com?abc=1&xyz=2' )
    assert_equal CfrLocationType.find_location_type( 'http://www.google.com?abc=1&xyz=2&test' ), cfr_location_types( :two )

    assert_nil CfrLocationType.find_location_type( '/' )
    assert_nil CfrLocationType.find_location_type( '/home/wr/Projects' )
    assert_nil CfrLocationType.find_location_type( '/home/wr/Projects/pmdb' )
    assert_equal CfrLocationType.find_location_type( '/home/wr/Projects/pmdb/pmodbase' ), cfr_location_types( :three )
  end

  test 'retrieve file name incl. extension' do
    lt = cfr_location_types( :one ) # windows
    assert_equal 'the.ext', lt.extract_file_name( 'X:\somewhere\over\the.ext' )
    assert_equal 'the.ext', lt.extract_file_name( 'X:\somewhere\over\the\rainbox\the.ext' )
    assert_equal 'the.ext', lt.extract_file_name( 'X:\the.ext' )
    assert_equal 'the.ext', lt.extract_file_name( 'the.ext' )

    lt = cfr_location_types( :two ) # internet
    assert_nil lt.extract_file_name( 'X:\somewhere\over\the.ext' )
    assert_nil lt.extract_file_name( 'X:\somewhere\over\the\rainbox\the.ext' )
    assert_nil lt.extract_file_name( 'X:\the.ext' )
    assert_nil lt.extract_file_name( 'the.ext' )
    assert_nil lt.extract_file_name( 'google.com' )
    #
    assert_equal 'the.ext', lt.extract_file_name( 'file://X:\somewhere\over\the.ext' )
    assert_equal 'the.ext', lt.extract_file_name( 'file://X:\somewhere\over\the\rainbox\the.ext' )
    assert_equal 'the.ext', lt.extract_file_name( 'file://X:\the.ext' )
    assert_equal 'the.ext', lt.extract_file_name( 'file://the.ext' )
    assert_equal 'ocean', lt.extract_file_name( 'file://down.under/in/the/dark/and/deep/ocean' )
    #
    lt = cfr_location_types( :three ) # unix
    assert_equal 'the.ext', lt.extract_file_name( '/home/wr/Projects/pmdb/the.ext' )
    assert_nil lt.extract_file_name( '/home/wr/Projects/pmdb/the/' )
  end

  test 'retrieve file extension' do
    assert_nil CfrLocationType.get_extension( 'X:\somewhere\over\the\rainbox' )
    assert_equal 'ext', CfrLocationType.get_extension( 'X:\somewhere\over\the\rainbox.ext' )
    assert_equal 'ext', CfrLocationType.get_extension( 'X:\somewhere\over\the\r.a.i.n.b.o.x.ext' )
  end

  test 'check for same location' do
    lt = cfr_location_types( :one )
    refute lt.same_location?( nil )
    refute lt.same_location?( '' )
    refute lt.same_location?( '  ' )
    refute lt.same_location?( 'X:\somewhere\over\the\rainbow')
    assert lt.same_location?( 'X:\somewhere\over\the\rainbow\test.ext' )
    assert lt.same_location?( 'X:\somewhere\over\the\rainbow\Test.ext' )
    refute lt.same_location?( 'X:\Somewhere\over\the\rainbow\test.ext' )
    assert lt.same_location?( 'x:\somewhere\over\the\rainbow\test.ext' )
  end

  test 'validate path prefix syntax - windows' do
    lt = cfr_location_types( :one )
    lt.location_type = 0

    lt.path_prefix = nil
    assert lt.valid?

    lt.path_prefix = 'C'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:\\'
    assert lt.valid?

    lt.path_prefix = 'C:\\?'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:\\test.*'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:\\test.doc'
    assert lt.valid?

    lt.path_prefix = 'C:\\temp\\test.doc'
    assert lt.valid?
  end

  test 'validate path prefix syntax - internet' do
    lt = cfr_location_types( :one )
    lt.location_type = 1

    lt.path_prefix = nil
    assert lt.valid?

    lt.path_prefix = 'C'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:\\'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:\\?'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:\\test.*'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:\\test.doc'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'C:\\temp\\test.doc'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    # - - -

    lt.path_prefix = 'http://'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'https://'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'ftp://'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'file://'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = 'file://c:\...'
    assert lt.valid?

    lt.path_prefix = 'http://test.pmodbase.cfl?format=xls'
    assert lt.valid?
    
  end

   test 'validate path prefix syntax - unix' do
    lt = cfr_location_types( :one )
    lt.location_type = 2

    lt.path_prefix = nil
    assert lt.valid?

    lt.path_prefix = '/'
    assert lt.valid?

    lt.path_prefix = '/home'
    assert lt.valid?

    lt.path_prefix = '/home?'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = '/home*'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = '/home/*.*'
    refute lt.valid?
    assert_includes lt.errors, :path_prefix

    lt.path_prefix = '/home/test.doc'
    assert lt.valid?, lt.errors.messages

    lt.path_prefix = '/home/temp/test.doc'
    assert lt.valid?
  end

  test 'complete code helper' do
    assert_equal 'A-0', cfr_location_types( :one ).complete_code( 'A', '0')
    assert_equal 'A_0', cfr_location_types( :two ).complete_code( 'A', '0')
  end

end
