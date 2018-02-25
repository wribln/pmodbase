require 'test_helper'
class CfrRecordsController0Test < ActionDispatch::IntegrationTest

  setup do
    @cfr_record = cfr_records( :one )
    @account = accounts( :one )
    signon_by_user @account
  end

  test 'should get index' do
    get cfr_records_path
    assert_response :success
    assert_not_nil assigns( :cfr_records )
    assert_not_nil assigns( :filter_fields )
    assert_not_nil assigns( :filter_groups )
    assert_not_nil assigns( :cfr_file_types )
  end

  test 'should get new' do
    get new_cfr_record_path
    assert_response :success
  end

  test 'should set defaults: doc_owner' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '' }}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal r.doc_owner, @account.account_info
    assert_empty r.errors
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
    assert_empty r.errors
  end

  test 'should set defaults' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        cfr_locations_attributes: [ '0',  uri: 'X:\blne058a\TS_TK_Proj\DNK_ODN\test.pdf', is_main_location: true ]}}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_empty r.errors
    assert_equal @account.account_info, r.doc_owner
    assert_equal 'pdf', r.extension
    assert_equal 'test', r.title
    assert_equal 'test.pdf', r.cfr_locations.first.file_name
    assert_equal cfr_location_types( :one ).id, r.cfr_locations.first.cfr_location_type.id
  end

  test 'should create cfr_record' do
    assert_difference('CfrRecord.count') do
      post cfr_records_path, params:{ cfr_record: { doc_date: @cfr_record.doc_date, doc_version: @cfr_record.doc_version, group_id: @cfr_record.group_id, main_location_id: @cfr_record.main_location_id, note: @cfr_record.note, title: @cfr_record.title }}
    end
    r = assigns( :cfr_record )
    assert_redirected_to cfr_record_path( r )
    assert_empty r.errors
  end

  test 'should show cfr_record' do
    get cfr_record_path( id: @cfr_record )
    assert_response :success
    r = assigns( :cfr_record )
    assert_empty r.errors
  end

  test 'should show details of cfr_record' do
    get cfr_record_path( id: @cfr_record )
    assert_response :success
    r = assigns( :cfr_record )
    assert_empty r.errors
  end

  test 'should get edit' do
    get edit_cfr_record_path( id: @cfr_record )
    assert_response :success
  end

  test 'should update cfr_record' do
    patch cfr_record_path( id: @cfr_record, params:{ cfr_record: { 
      doc_date: @cfr_record.doc_date,
      doc_version: @cfr_record.doc_version,
      group_id: @cfr_record.group_id,
      main_location_id: @cfr_record.main_location_id,
      note: @cfr_record.note, 
      title: @cfr_record.title }})
    r = assigns( :cfr_record )
    assert_redirected_to cfr_record_path( r )
    assert_empty r.errors
  end

  test 'should update defaults' do
    patch cfr_record_path( id: @cfr_record, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '', extension: 'pdf' }})
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal r.doc_owner, @account.account_info
    assert_equal cfr_file_types( :two ).id, r.cfr_file_type_id
    assert_empty r.errors
  end

  test 'should destroy cfr_record' do
    assert_difference('CfrRecord.count', -1) do
      delete cfr_record_path( id: @cfr_record )
    end
    assert_redirected_to cfr_records_path
  end

end
