require 'test_helper'
class A6CodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    a6 = A6Code.new
    assert_nil a6.code
    assert_nil a6.label
    assert a6.active 
    assert a6.master
    assert_nil a6.mapping
  end

  test 'check fixture' do
    a6 = a6_codes( :one )
    refute_nil a6.code
    refute_nil a6.label
    assert a6.active
    assert a6.master
    refute_nil a6.mapping
    assert a6.valid?
  end

  test 'code syntax' do
    a6 = a6_codes( :one )

    a6.code = ''
    refute a6.valid?
    assert_includes a6.errors, :code

    a6.code = ' '
    refute a6.valid?
    assert_includes a6.errors, :code

    a6.code = 'abc'
    refute a6.valid?
    assert_includes a6.errors, :code

    a6.code = '1'
    refute a6.valid?
    assert_includes a6.errors, :code

    a6.code = '?'
    refute a6.valid?
    assert_includes a6.errors, :code

    a6.code = 'ABCD'
    refute a6.valid?
    assert_includes a6.errors, :code
  end

  test 'code and label' do
    a6 = a6_codes( :one )
    a6.code = 'ABC'
    a6.label = 'Test'
    assert a6.valid?
    assert_equal 'ABC - Test', a6.code_and_label
  end

  test 'only one master should exist' do
    a6 = a6_codes( :one )
    an = a6.dup
    refute an.valid?
    assert_includes an.errors, :base
    an.master = false
    assert an.valid?, a6.errors.messages
  end

end
