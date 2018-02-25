require 'test_helper'
class CfrRecordsController2Test < ActionDispatch::IntegrationTest

  setup do
    @account = accounts( :one )
    signon_by_user @account
  end

  test 'should set defaults: doc_owner' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '' }}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal r.doc_owner, @account.account_info
  end

  test 'should set defaults: extension' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        extension: '',
        cfr_locations_attributes: [ file_name: 'test.pdf', is_main_location: true ]}}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal 'pdf', r.extension
  end

  test 'should set defaults: main location' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        extension: '',
        cfr_locations_attributes: [ uri: 'X:\blne058a\TS_TK_Proj\DNK_ODN\test%20with%20blanks.pdf' ]}}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert r.cfr_locations.first.is_main_location
    assert_equal 'test with blanks.pdf', r.cfr_locations.first.file_name
    assert_equal 'test with blanks', r.title
    assert_equal 'pdf', r.extension
    assert_equal r.cfr_file_type, cfr_file_types( :two )
  end

  test 'should set defaults' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        cfr_locations_attributes: [ '0',  uri: 'X:\blne058a\TS_TK_Proj\DNK_ODN\test.pdf', is_main_location: true ]}}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal @account.account_info, r.doc_owner
    assert_equal 'pdf', r.extension
    assert_equal 'test', r.title
    assert_equal 'test.pdf', r.cfr_locations.first.file_name
    assert_equal cfr_location_types( :one ).id, r.cfr_locations.first.cfr_location_type.id
  end

  test 'should not set main location' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        cfr_locations_attributes: {
          '0' => { uri: 'X:\blne058a\TS_TK_Proj\DNK_ODN\a%20file%20with%20blanks' },
          '1' => { uri: 'https://www.xxx.com/inside/test.pdf' }}}}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_nil r.main_location
    assert_equal @account.account_info, r.doc_owner
    assert_nil r.extension
    assert_nil r.title
    assert_equal 'a file with blanks', r.cfr_locations.first.file_name
    assert_nil r.cfr_locations.last.file_name
    assert_equal cfr_location_types( :one ), r.cfr_locations.first.cfr_location_type
    assert_nil r.cfr_locations.last.cfr_location_type
  end

end
