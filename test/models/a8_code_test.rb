require 'test_helper'
class A8CodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    a8 = A8Code.new
    assert_nil a8.code
    assert_nil a8.label
    assert a8.active 
    assert a8.master
    assert_nil a8.mapping
  end

  test 'check fixture' do
    a8 = a8_codes( :one )
    refute_nil a8.code
    refute_nil a8.label
    assert a8.active
    assert a8.master
    refute_nil a8.mapping
    assert a8.valid?
  end

  test 'code syntax' do
    a8 = a8_codes( :one )

    a8.code = ''
    refute a8.valid?
    assert_includes a8.errors, :code

    a8.code = ' '
    refute a8.valid?
    assert_includes a8.errors, :code

    a8.code = 'abc'
    refute a8.valid?
    assert_includes a8.errors, :code

    a8.code = '1'
    refute a8.valid?
    assert_includes a8.errors, :code

    a8.code = '?'
    refute a8.valid?
    assert_includes a8.errors, :code

    a8.code = 'ABCD'
    refute a8.valid?
    assert_includes a8.errors, :code
  end

  test 'code and label' do
    a8 = a8_codes( :one )
    a8.code = 'ABC'
    a8.label = 'Test'
    assert a8.valid?
    assert_equal 'ABC - Test', a8.code_and_label
  end

  test 'only one master should exist' do
    a8 = a8_codes( :one )
    an = a8.dup
    refute an.valid?
    assert_includes an.errors, :base
    an.master = false
    assert an.valid?, a8.errors.messages
  end

end
