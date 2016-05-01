require 'test_helper'
class A2CodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    a2 = A2Code.new
    assert_nil a2.code
    assert_nil a2.label
    assert a2.active 
    assert a2.master
    assert_nil a2.mapping
  end

  test 'check fixture' do
    a2 = a2_codes( :one )
    refute_nil a2.code
    refute_nil a2.label
    assert a2.active
    assert a2.master
    refute_nil a2.mapping
    assert a2.valid?
  end

  test 'code syntax' do
    a2 = a2_codes( :one )

    a2.code = ''
    refute a2.valid?
    assert_includes a2.errors, :code

    a2.code = ' '
    refute a2.valid?
    assert_includes a2.errors, :code

    a2.code = 'abc'
    refute a2.valid?
    assert_includes a2.errors, :code

    a2.code = '1'
    refute a2.valid?
    assert_includes a2.errors, :code

    a2.code = '?'
    refute a2.valid?
    assert_includes a2.errors, :code

    a2.code = 'ABCD'
    refute a2.valid?
    assert_includes a2.errors, :code
  end

  test 'code and label' do
    a2 = a2_codes( :one )
    a2.code = '123'
    a2.label = 'Test'
    assert a2.valid?
    assert_equal '123 - Test', a2.code_and_label
  end

  test 'only one master should exist' do
    a2 = a2_codes( :one )
    an = a2.dup
    refute an.valid?
    assert_includes an.errors, :base
    an.master = false
    assert an.valid?, a2.errors.messages
  end

  test 'all scopes' do
    as = A2Code.std_order
    assert_equal 1, as.length

    as = A2Code.active_only
    assert_equal 1, as.length

    as = A2Code.as_code( '1' )
    assert_equal 1, as.length

    as = A2Code.as_code( 'Z' )
    assert_equal 0, as.length
  end

end
