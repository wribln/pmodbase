require 'test_helper'
class A3CodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    a3 = A3Code.new
    assert_nil a3.code
    assert_nil a3.label
    assert a3.active 
    assert a3.master
    assert_nil a3.mapping
  end

  test 'check fixture' do
    a3 = a3_codes( :one )
    refute_nil a3.code
    refute_nil a3.label
    assert a3.active
    assert a3.master
    refute_nil a3.mapping
    assert a3.valid?
  end

  test 'code syntax' do
    a3 = a3_codes( :one )

    a3.code = ''
    refute a3.valid?
    assert_includes a3.errors, :code

    a3.code = ' '
    refute a3.valid?
    assert_includes a3.errors, :code

    a3.code = 'abc'
    refute a3.valid?
    assert_includes a3.errors, :code

    a3.code = '1'
    refute a3.valid?
    assert_includes a3.errors, :code

    a3.code = '?'
    refute a3.valid?
    assert_includes a3.errors, :code

    a3.code = 'ABCD'
    refute a3.valid?
    assert_includes a3.errors, :code
  end

  test 'code and label' do
    a3 = a3_codes( :one )
    a3.code = 'ABC'
    a3.label = 'Test'
    assert a3.valid?
    assert_equal 'ABC - Test', a3.code_and_label
  end

  test 'only one master should exist' do
    a3 = a3_codes( :one )
    an = a3.dup
    refute an.valid?
    assert_includes an.errors, :base
    an.master = false
    assert an.valid?, a3.errors.messages
  end

end
