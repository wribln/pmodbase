require 'test_helper'
class SDocumentLogTest < ActiveSupport::TestCase

  test 'fixture' do
    sdl = s_document_logs( :one )
    assert_equal 'TWO', sdl.receiver_group
    assert_equal '=ABC', sdl.function_code
    assert_equal '$ABC', sdl.service_code
    assert_equal '-ABC', sdl.product_code
    assert_equal '+1.ST.01', sdl.location_code
    assert_equal '%PM200', sdl.phase_code
    assert_equal '&ABC', sdl.dcc_code
    sdl.valid?
  end

  test 'defaults' do
    sdl = SDocumentLog.new
    refute sdl.valid?
    assert_includes sdl.errors, :dcc_code
    assert_includes sdl.errors, :group_id

    sdl.dcc_code ="&ABC"
    sdl.group_id = s_document_logs( :one ).group_id
    refute sdl.valid?
    assert_includes sdl.errors, :base

    sdl.function_code = ''
    refute sdl.valid?

    sdl.function_code = '=ABC'
    assert sdl.valid?, sdl.errors.messages

    sdl.function_code = nil
    sdl.service_code = ''
    refute sdl.valid?

    sdl.service_code = '$ABC'
    assert sdl.valid?, sdl.errors.messages

    sdl.service_code = nil
    sdl.product_code = ''
    refute sdl.valid?

    sdl.product_code = '-ABC'
    assert sdl.valid?, sdl.errors.messages

    sdl.product_code = nil
    sdl.phase_code = ''
    refute sdl.valid?
    
    sdl.phase_code = '%PM200'
    assert sdl.valid?, sdl.errors.messages
  end

  test 'create document code' do
    sdl = s_document_logs( :one )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id

    sdl.receiver_group = nil
    sdl.siemens_doc_id = sdl.siemens_doc_id.sub( ')TWO', '' )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

    sdl.receiver_group = ''
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

    sdl.revision_code = nil
    sdl.siemens_doc_id = sdl.siemens_doc_id.sub( '_0', '' )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

    sdl.revision_code = ''
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

    sdl.function_code = nil
    sdl.siemens_doc_id = sdl.siemens_doc_id.sub( '=ABC', '' )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

    sdl.service_code = nil
    sdl.siemens_doc_id = sdl.siemens_doc_id.sub( '$ABC', '' )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

    sdl.product_code = nil
    sdl.siemens_doc_id = sdl.siemens_doc_id.sub( '-ABC', '' )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

    sdl.location_code = nil
    sdl.siemens_doc_id = sdl.siemens_doc_id.sub( '+1.ST.01', '' )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

    s_code = sdl.siemens_doc_id
    sdl.siemens_doc_id = nil
    assert sdl.valid?
    sdl.save
    assert_equal s_code, sdl.siemens_doc_id

    sdl.phase_code = nil
    sdl.siemens_doc_id = sdl.siemens_doc_id.sub( '%PM200', '' )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    refute sdl.valid?
    sdl.function_code = '=ABC'
    assert sdl.valid?

    # need to test author date last as a missing author date
    # will cause today's date to be used as default

    sdl.author_date = nil
    sdl.siemens_doc_id = sdl.siemens_doc_id.sub( '&ABC_20160303', '=ABC&ABC' )
    assert_equal sdl.siemens_doc_id, sdl.create_siemens_doc_id
    assert sdl.valid?

  end

end
