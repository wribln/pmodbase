require 'test_helper'
class A5CodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    a5 = A5Code.new
    assert_nil a5.code
    assert_nil a5.label
    assert a5.active 
    assert a5.master
    assert_nil a5.mapping
  end

  test 'check fixture' do
    a5 = a5_codes( :one )
    refute_nil a5.code
    refute_nil a5.label
    assert a5.active
    assert a5.master
    refute_nil a5.mapping
    assert a5.valid?
  end

  test 'code syntax' do
    a5 = a5_codes( :one )

    a5.code = ''
    refute a5.valid?
    assert_includes a5.errors, :code

    a5.code = ' '
    refute a5.valid?
    assert_includes a5.errors, :code

    a5.code = 'abc'
    refute a5.valid?
    assert_includes a5.errors, :code

    a5.code = '1'
    refute a5.valid?
    assert_includes a5.errors, :code

    a5.code = '?'
    refute a5.valid?
    assert_includes a5.errors, :code

    a5.code = 'ABCD'
    refute a5.valid?
    assert_includes a5.errors, :code
  end

  test 'code and label' do
    a5 = a5_codes( :one )
    a5.code = 'ABC'
    a5.label = 'Test'
    assert a5.valid?
    assert_equal 'ABC - Test', a5.code_and_label
  end

  test 'only one master should exist' do
    a5 = a5_codes( :one )
    an = a5.dup
    refute an.valid?
    assert_includes an.errors, :base
    an.master = false
    assert an.valid?, a5.errors.messages
  end

  test 'all scopes' do
    as = A5Code.std_order
    assert_equal 1, as.length

    as = A5Code.active_only
    assert_equal 1, as.length

    as = A5Code.as_code( 'A' )
    assert_equal 1, as.length

    as = A5Code.as_code( 'Z' )
    assert_equal 0, as.length

    as = A5Code.as_desc( 'Alpha')
    assert_equal 1, as.length

    as = A5Code.as_desc( 'what')
    assert_equal 1, as.length

    as = A5Code.as_desc( 'foobar')
    assert_equal 0, as.length
  end
end
