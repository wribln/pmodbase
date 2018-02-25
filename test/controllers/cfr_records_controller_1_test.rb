require 'test_helper'
class CfrRecordsController1Test < ActionDispatch::IntegrationTest

  setup do
    @cfr_record = cfr_records( :one )
    @account = accounts( :wop )
    signon_by_user @account
  end

  test 'should get index' do
    get cfr_records_path
    assert_response :success
    r = assigns( :cfr_records )
    assert_not_nil r 
    assert_equal 1, r.length
    assert_not_nil assigns( :filter_fields )
    assert_not_nil assigns( :filter_groups )
    assert_not_nil assigns( :cfr_file_types )
  end

  test 'should get new' do
    get new_cfr_record_path
    assert_response :unauthorized
  end

  test 'should set defaults: doc_owner' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '' }}
    end
    assert_response :unauthorized
  end

  test 'should set defaults: extension' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        extension: '',
        cfr_locations_attributes: [ file_name: 'test.pdf', is_main_location: true ]}}
    end
    assert_response :unauthorized
  end

  test 'should set defaults' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        cfr_locations_attributes: [ '0',  uri: 'X:\somewhere\over\the\rainbow\test.pdf', is_main_location: true ]}}
    end
    assert_response :unauthorized
  end

  test 'should create cfr_record' do
    assert_no_difference( 'CfrRecord.count' ) do
      post cfr_records_path, params:{ cfr_record: { doc_date: @cfr_record.doc_date, doc_version: @cfr_record.doc_version, group_id: @cfr_record.group_id, main_location_id: @cfr_record.main_location_id, note: @cfr_record.note, title: @cfr_record.title }}
    end
    assert_response :unauthorized
  end

  test 'should show cfr_record' do
    assert_nil @cfr_record.group_id
    assert @cfr_record.conf_level == 0
    get cfr_record_path( id: @cfr_record )
    assert_response :success
  end

  test 'should show details of cfr_record' do
    assert_nil @cfr_record.group_id
    assert @cfr_record.conf_level == 0
    get cfr_record_details_path( id: @cfr_record )
    assert_response :success
  end

  test 'should get edit' do
    get edit_cfr_record_path( id: @cfr_record )
    assert_response :unauthorized
  end

  test 'should update cfr_record' do
    patch cfr_record_path( id: @cfr_record, params:{ cfr_record: { 
      doc_date: @cfr_record.doc_date,
      doc_version: @cfr_record.doc_version,
      group_id: @cfr_record.group_id,
      main_location_id: @cfr_record.main_location_id,
      note: @cfr_record.note, 
      title: @cfr_record.title }})
    assert_response :unauthorized
  end

  test 'should update defaults' do
    patch cfr_record_path( id: @cfr_record, params:{ commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '', extension: 'pdf' }})
    assert_response :unauthorized
  end

  test 'should destroy cfr_record' do
    assert_no_difference( 'CfrRecord.count' ) do
      delete cfr_record_path( id: @cfr_record )
    end
    assert_response :unauthorized
  end
end
