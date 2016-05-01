require 'test_helper'
class A1CodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    a1 = A1Code.new
    assert_nil a1.code
    assert_nil a1.label
    assert a1.active 
    assert a1.master
    assert_nil a1.mapping
  end

  test 'check fixture' do
    a1 = a1_codes( :one )
    refute_nil a1.code
    refute_nil a1.label
    assert a1.active
    assert a1.master
    refute_nil a1.mapping
    assert a1.valid?
  end

  test 'code syntax' do
    a1 = a1_codes( :one )

    a1.code = ''
    refute a1.valid?
    assert_includes a1.errors, :code

    a1.code = ' '
    refute a1.valid?
    assert_includes a1.errors, :code

    a1.code = 'abc'
    refute a1.valid?
    assert_includes a1.errors, :code

    a1.code = '1'
    refute a1.valid?
    assert_includes a1.errors, :code

    a1.code = '?'
    refute a1.valid?
    assert_includes a1.errors, :code

    a1.code = 'ABCD'
    refute a1.valid?
    assert_includes a1.errors, :code
  end

  test 'code and label' do
    a1 = a1_codes( :one )
    a1.code = 'ABC'
    a1.label = 'Test'
    assert a1.valid?
    assert_equal 'ABC - Test', a1.code_and_label
  end

  test 'only one master should exist' do
    a1 = a1_codes( :one )
    an = a1.dup
    refute an.valid?
    assert_includes an.errors, :base
    an.master = false
    assert an.valid?, a1.errors.messages
  end

  test 'all scopes' do
    as = A1Code.std_order
    assert_equal 1, as.length

    as = A1Code.active_only
    assert_equal 1, as.length

    as = A1Code.as_code( 'A' )
    assert_equal 1, as.length

    as = A1Code.as_code( 'Z' )
    assert_equal 0, as.length
  end

end
