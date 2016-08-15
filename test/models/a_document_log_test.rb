require 'test_helper'
class ADocumentLogTest < ActiveSupport::TestCase

  test 'fixtures' do
    adl = a_document_logs( :one )
    assert_equal 'ABC', adl.a1_code
    assert_equal '123', adl.a2_code
    assert_equal 'ABC', adl.a3_code
    assert_equal 'DEF', adl.a4_code
    assert_equal 'ABC', adl.a5_code
    assert_equal 'ABC', adl.a6_code
    assert_equal 'ABC', adl.a7_code
    assert_equal 'ABC', adl.a8_code
    adl.valid?

    assert A1Code.active_only.where( code: 'ABC' ).exists?
    assert A2Code.active_only.where( code: '123' ).exists?
    assert A3Code.active_only.where( code: 'ABC' ).exists?
    assert A4Code.active_only.where( code: 'ABC-DEF' ).exists?
    assert A5Code.active_only.where( code: 'ABC' ).exists?
    assert A6Code.active_only.where( code: 'ABC' ).exists?
    assert A7Code.active_only.where( code: 'ABC' ).exists?
    assert A8Code.active_only.where( code: 'ABC' ).exists?
  end

  test 'defaults' do
    adl = ADocumentLog.new
    refute adl.valid?
    assert_includes adl.errors, :a1_code
    assert_includes adl.errors, :a2_code
    assert_includes adl.errors, :a3_code
    assert_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a1_code = 'XYZ'
    refute adl.valid?
    assert_includes adl.errors, :a1_code
    assert_includes adl.errors, :a2_code
    assert_includes adl.errors, :a3_code
    assert_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a1_code = 'ABC'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    assert_includes adl.errors, :a2_code
    assert_includes adl.errors, :a3_code
    assert_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a2_code = '000'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    assert_includes adl.errors, :a2_code
    assert_includes adl.errors, :a3_code
    assert_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a2_code = '123'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    assert_includes adl.errors, :a3_code
    assert_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a3_code = 'XYZ'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    assert_includes adl.errors, :a3_code
    assert_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a3_code = 'ABC'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    assert_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a4_code = 'ABC'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    assert_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a4_code = 'DEF'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    refute_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a5_code = 'XYZ'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    refute_includes adl.errors, :a4_code
    assert_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a5_code = 'ABC'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    refute_includes adl.errors, :a4_code
    refute_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a6_code = 'XYZ'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    refute_includes adl.errors, :a4_code
    refute_includes adl.errors, :a5_code
    assert_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a6_code = 'ABC'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    refute_includes adl.errors, :a4_code
    refute_includes adl.errors, :a5_code
    refute_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a7_code = 'XYZ'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    refute_includes adl.errors, :a4_code
    refute_includes adl.errors, :a5_code
    refute_includes adl.errors, :a6_code
    assert_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a7_code = 'ABC'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    refute_includes adl.errors, :a4_code
    refute_includes adl.errors, :a5_code
    refute_includes adl.errors, :a6_code
    refute_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a8_code = 'XYZ'
    refute adl.valid?
    refute_includes adl.errors, :a1_code
    refute_includes adl.errors, :a2_code
    refute_includes adl.errors, :a3_code
    refute_includes adl.errors, :a4_code
    refute_includes adl.errors, :a5_code
    refute_includes adl.errors, :a6_code
    refute_includes adl.errors, :a7_code
    assert_includes adl.errors, :a8_code

    adl.a8_code = 'ABC'
    adl.account = accounts( :wop )
    assert adl.valid?, adl.errors.messages

  end

  test 'create document code' do
    adl = a_document_logs( :one )
    assert_equal adl.doc_id, adl.create_alt_doc_id
  end

  test 'all scopes' do
    as = ADocumentLog.reverse
    assert_equal 1, as.length

    as = ADocumentLog.inorder
    assert_equal 1, as.length

    as = ADocumentLog.ff_srec( a_document_logs( :one ).id )
    assert_equal 1, as.length

    as = ADocumentLog.ff_srec( 0 )
    assert_equal 0, as.length

    as = ADocumentLog.ff_adic( '123' )
    assert_equal 1, as.length

    as = ADocumentLog.ff_adic( 'foobar' )
    assert_equal 0, as.length

    as = ADocumentLog.ff_titl( 'Test' )
    assert_equal 1, as.length

    as = ADocumentLog.ff_titl( 'foobar' )
    assert_equal 0, as.length

  end

end
