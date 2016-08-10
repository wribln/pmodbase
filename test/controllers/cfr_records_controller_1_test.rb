require 'test_helper'
class CfrRecordsController1Test < ActionController::TestCase
  tests CfrRecordsController

  setup do
    @cfr_record = cfr_records( :one )
    @account = accounts( :account_wop )
    session[ :current_user_id ] = accounts( :account_wop ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    r = assigns( :cfr_records )
    assert_not_nil r 
    assert_equal 1, r.length
    assert_not_nil assigns( :filter_fields )
    assert_not_nil assigns( :filter_groups )
    assert_not_nil assigns( :cfr_file_types )
  end

  test 'should get new' do
    get :new
    assert_response :unauthorized
  end

  test 'should set defaults: doc_owner' do
    assert_no_difference( 'CfrRecord.count' ) do
      post :create, commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '' }
    end
    assert_response :unauthorized
  end

  test 'should set defaults: extension' do
    assert_no_difference( 'CfrRecord.count' ) do
      post :create, commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        extension: '',
        cfr_locations_attributes: [ file_name: 'test.pdf', is_main_location: true ]}
    end
    assert_response :unauthorized
  end

  test 'should set defaults' do
    assert_no_difference( 'CfrRecord.count' ) do
      post :create, commit: I18n.t( 'button_label.defaults' ), cfr_record: {
        cfr_locations_attributes: [ '0',  uri: 'X:\somewhere\over\the\rainbow\test.pdf', is_main_location: true ]}
    end
    assert_response :unauthorized
  end

  test 'should create cfr_record' do
    assert_no_difference( 'CfrRecord.count' ) do
      post :create, cfr_record: { doc_date: @cfr_record.doc_date, doc_version: @cfr_record.doc_version, group_id: @cfr_record.group_id, main_location_id: @cfr_record.main_location_id, note: @cfr_record.note, title: @cfr_record.title }
    end
    assert_response :unauthorized
  end

  test 'should show cfr_record' do
    get :show, id: @cfr_record
    assert_response :unauthorized
  end

  test 'should show details of cfr_record' do
    get :show_all, id: @cfr_record
    assert_response :unauthorized
  end

  test 'should get edit' do
    get :edit, id: @cfr_record
    assert_response :unauthorized
  end

  test 'should update cfr_record' do
    patch :update, id: @cfr_record, cfr_record: { 
      doc_date: @cfr_record.doc_date,
      doc_version: @cfr_record.doc_version,
      group_id: @cfr_record.group_id,
      main_location_id: @cfr_record.main_location_id,
      note: @cfr_record.note, 
      title: @cfr_record.title }
    assert_response :unauthorized
  end

  test 'should update defaults' do
    patch :update, id: @cfr_record, commit: I18n.t( 'button_label.defaults' ), cfr_record: { doc_owner: '', extension: 'pdf' }
    assert_response :unauthorized
  end

  test 'should destroy cfr_record' do
    assert_no_difference( 'CfrRecord.count' ) do
      delete :destroy, id: @cfr_record
    end
    assert_response :unauthorized
  end
end
