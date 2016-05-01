require 'test_helper'
class A4CodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    a4 = A4Code.new
    assert_nil a4.code
    assert_nil a4.label
    assert a4.active 
    assert a4.master
    assert_nil a4.mapping
  end

  test 'check fixture' do
    a4 = a4_codes( :one )
    refute_nil a4.code
    refute_nil a4.label
    assert a4.active
    assert a4.master
    refute_nil a4.mapping
    assert a4.valid?
  end

  test 'code syntax' do
    a4 = a4_codes( :one )

    a4.code = ''
    refute a4.valid?
    assert_includes a4.errors, :code

    a4.code = ' '
    refute a4.valid?
    assert_includes a4.errors, :code

    a4.code = 'abc'
    refute a4.valid?
    assert_includes a4.errors, :code

    a4.code = '1'
    refute a4.valid?
    assert_includes a4.errors, :code

    a4.code = '?'
    refute a4.valid?
    assert_includes a4.errors, :code

    a4.code = 'ABCD'
    refute a4.valid?
    assert_includes a4.errors, :code
  end

  test 'code and label' do
    a4 = a4_codes( :one )
    a4.code = 'ABC-ABC'
    a4.label = 'Test'
    assert a4.valid?
    assert_equal 'ABC-ABC - Test', a4.code_and_label
  end

  test 'only one master should exist' do
    a4 = a4_codes( :one )
    an = a4.dup
    refute an.valid?
    assert_includes an.errors, :base
    an.master = false
    assert an.valid?, a4.errors.messages
  end

  test 'code syntax - 2' do
    a4 = a4_codes( :one )

    a4.code = 'ABC-'
    refute a4.valid?
    assert_includes a4.errors, :code

    a4.code = 'ABC-abc'
    refute a4.valid?
    assert_includes a4.errors, :code

    a4.code = 'ABC-?'
    refute a4.valid?
    assert_includes a4.errors, :code

    a4.code = 'ABC-HAHA'
    refute a4.valid?
    assert_includes a4.errors, :code
  end

  test 'all scopes' do
    as = A4Code.std_order
    assert_equal 1, as.length

    as = A4Code.active_only
    assert_equal 1, as.length

    as = A4Code.as_code( 'D' )
    assert_equal 1, as.length

    as = A4Code.as_code( 'A' )
    assert_equal 0, as.length
  end


end
