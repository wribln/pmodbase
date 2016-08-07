require 'test_helper'
class CfrRecordsController0Test < ActionController::TestCase
  tests CfrRecordsController

  setup do
    @cfr_record = cfr_records( :one )
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :cfr_records )
    assert_not_nil assigns( :filter_fields )
    assert_not_nil assigns( :filter_groups )
    assert_not_nil assigns( :cfr_file_types )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should set defaults: doc_owner' do
    assert_no_difference( 'CfrRecord.count' ) do
      post :create, commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '' }
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal r.doc_owner, @account.account_info
  end

  test 'should set defaults: extension' do
    assert_no_difference( 'CfrRecord.count' ) do
      post :create, commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        extension: '',
        cfr_locations_attributes: [ file_name: 'test.pdf', is_main_location: true ]}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal 'pdf', r.extension
  end

  test 'should set defaults' do
    assert_no_difference( 'CfrRecord.count' ) do
      post :create, commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        cfr_locations_attributes: [ '0',  uri: 'X:\somewhere\over\the\rainbow\test.pdf', is_main_location: true ]}
    end
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal @account.account_info, r.doc_owner
    assert_equal 'pdf', r.extension
    assert_equal 'test', r.title
    assert_equal 'test.pdf', r.cfr_locations.first.file_name
    assert_equal cfr_location_types( :one ).id, r.cfr_locations.first.cfr_location_type.id
  end

  test 'should create cfr_record' do
    assert_difference('CfrRecord.count') do
      post :create, cfr_record: { doc_date: @cfr_record.doc_date, doc_version: @cfr_record.doc_version, group_id: @cfr_record.group_id, main_location_id: @cfr_record.main_location_id, note: @cfr_record.note, title: @cfr_record.title }
    end
    assert_redirected_to cfr_record_path( assigns( :cfr_record ))
  end

  test 'should show cfr_record' do
    get :show, id: @cfr_record
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @cfr_record
    assert_response :success
  end

  test 'should update cfr_record' do
    patch :update, id: @cfr_record, cfr_record: { 
      doc_date: @cfr_record.doc_date,
      doc_version: @cfr_record.doc_version,
      group_id: @cfr_record.group_id,
      main_location_id: @cfr_record.main_location_id,
      note: @cfr_record.note, 
      title: @cfr_record.title }
    assert_redirected_to cfr_record_path( assigns( :cfr_record ))
  end

  test 'should update defaults' do
    patch :update, id: @cfr_record, commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '', extension: 'pdf' }
    assert_response :success
    r = assigns( :cfr_record )
    assert_equal r.doc_owner, @account.account_info
    assert_equal cfr_file_types( :two ).id, r.cfr_file_type_id
  end

  test 'should destroy cfr_record' do
    assert_difference('CfrRecord.count', -1) do
      delete :destroy, id: @cfr_record
    end

    assert_redirected_to cfr_records_path
  end
end
