require 'test_helper'
class CfrFileTypeTest < ActiveSupport::TestCase

  test 'check fixture 1' do 
    ft = cfr_file_types( :one )
    assert ft.valid?
    assert ft.extensions.include? 'xlt'
    refute ft.extensions.include? 'xxx'
  end

  test 'check fixture 2' do
    ft = cfr_file_types( :two )
    assert ft.valid?
    assert ft.extensions.include? 'pdf'
    refute ft.extensions.include? 'xxx'
  end

  test 'default' do
    ft = CfrFileType.new
    assert_nil ft.extensions
    assert_nil ft.label
    refute ft.valid?
    assert_includes ft.errors, :extensions
  end

  test 'no duplicate extension' do
    ftx = cfr_file_types( :one )
    ftn = CfrFileType.new( extensions: ftx.extensions )
    refute ftn.valid?
    assert_includes ftn.errors, :extensions
  end

  test 'get file type label 1' do
    ft = cfr_file_types( :one )
    assert_equal ft.label, CfrFileType.file_type_label( 'xlt' )
  end

  test 'get file type label 2' do
    ft = cfr_file_types( :two )
    assert_equal ft.label, CfrFileType.file_type_label( 'pdf' )
  end

  test 'get file type unknown' do
    assert_equal CfrFileType.human_attribute_name( :unknown_type ), CfrFileType.file_type_label( nil )
    assert_equal CfrFileType.human_attribute_name( :unknown_type ), CfrFileType.file_type_label( '' )
    assert_equal CfrFileType.human_attribute_name( :unknown_type ), CfrFileType.file_type_label( ' ' )
    assert_equal CfrFileType.human_attribute_name( :unknown_type ), CfrFileType.file_type_label( 'xxx' )
  end

  test 'get file type' do
    assert_nil CfrFileType.get_file_type( nil )
    assert_nil CfrFileType.get_file_type( '' )
    assert_nil CfrFileType.get_file_type( 'xxx' )
    assert_equal cfr_file_types( :one ), CfrFileType.get_file_type( 'xlm' )
    assert_equal cfr_file_types( :one ), CfrFileType.get_file_type( 'xls' )
    assert_equal cfr_file_types( :one ), CfrFileType.get_file_type( 'xlt' )
    assert_equal cfr_file_types( :two ), CfrFileType.get_file_type( 'pdf' )
  end
end
