require 'test_helper'
class CfrFileTypeTest < ActiveSupport::TestCase

  test 'check fixture 1' do 
    ft = cfr_file_types( :one )
    assert ft.valid?, ft.errors.messages
    assert ft.extensions.include? 'xlt'
    refute ft.extensions.include? 'xxx'
  end

  test 'check fixture 2' do
    ft = cfr_file_types( :two )
    assert ft.valid?, ft.errors.messages
    assert ft.extensions.include? 'pdf'
    refute ft.extensions.include? 'xxx'
  end

  test 'default' do
    ft = CfrFileType.new
    assert_nil ft.extensions
    assert_nil ft.label
    refute ft.valid?
    assert_includes ft.errors, :label
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
    assert_equal ft.label, CfrFileType.file_type_label( 'XLT' )
  end

  test 'get file type label 2' do
    ft = cfr_file_types( :two )
    assert_equal ft.label, CfrFileType.file_type_label( 'pdf' )
    assert_equal ft.label, CfrFileType.file_type_label( 'PDF' )
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

  test 'scope lower case' do
    assert_equal 1, CfrFileType.find_by_extension( 'pdf' ).count
    assert_equal 1, CfrFileType.find_by_extension( 'xlm' ).count
    assert_equal 0, CfrFileType.find_by_extension( 'xl' ).count
    assert_equal 0, CfrFileType.find_by_extension( 'x' ).count
    assert_equal 0, CfrFileType.find_by_extension( 'y' ).count
  end

  test 'scope upper case' do
    assert_equal 1, CfrFileType.find_by_extension( 'PDF' ).count
    assert_equal 1, CfrFileType.find_by_extension( 'XLM' ).count
    assert_equal 0, CfrFileType.find_by_extension( 'XL' ).count
    assert_equal 0, CfrFileType.find_by_extension( 'X' ).count
    assert_equal 0, CfrFileType.find_by_extension( 'Y' ).count
  end

  test 'uniqueness of extension' do
    ft1 = cfr_file_types( :two )
    assert ft1.extensions.include? 'pdf'
    ft2 = CfrFileType.new
    ft2.label = 'test'
    ft2.extensions = 'pdf'
    refute ft2.valid?
    assert_includes ft2.errors, :extensions
  end

  test 'empty extension list' do
    ft = CfrFileType.new
    ft.label = 'Folder'
    assert ft.valid?, ft.errors.messages
  end

end
