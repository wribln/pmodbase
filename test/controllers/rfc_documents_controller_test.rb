require 'test_helper'
class RfcDocumentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @rfc_document = rfc_documents( :one )
  end

  test 'check class_attributes'  do
    get rfc_documents_path
    validate_feature_class_attributes FEATURE_ID_RFC_DOCUMENTS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get rfc_documents_path
    assert_response :success
    assert_not_nil assigns( :rfc_documents )
  end

  test 'should get new' do
    get new_rfc_document_path
    assert_response :success
  end

  test 'should create rfc_document' do
    assert_difference( 'RfcDocument.count' ) do
      post rfc_documents_path, params:{ rfc_document: {
        rfc_status_record_id: @rfc_document.rfc_status_record_id,
        version:  1,
        answer:   'an answer',
        note:     'a note',
        question: 'and a question' }}
    end
    assert_redirected_to rfc_document_path( assigns( :rfc_document ))
    assert_equal accounts( :one ).id,assigns( :rfc_document ).account_id
  end

  test 'should show rfc_document' do
    get rfc_document_path( id: @rfc_document )
    assert_response :success
  end

  test 'should get edit' do
    get edit_rfc_document_path( id: @rfc_document )
    assert_response :success
  end

  test 'should update rfc_document' do
    patch rfc_document_path( id: @rfc_document, params:{ rfc_document: {
      version:  @rfc_document.version, 
      answer:   @rfc_document.answer, 
      note:     @rfc_document.note, 
      question: @rfc_document.question }})
    assert_redirected_to rfc_document_path( assigns( :rfc_document ))
    assert_equal rfc_documents( :one ).account_id,assigns( :rfc_document ).account_id
  end

  test 'should destroy rfc_document' do
    assert_difference('RfcDocument.count', -1) do
      delete rfc_document_path( id: @rfc_document )
    end

    assert_redirected_to rfc_documents_path
  end
end
