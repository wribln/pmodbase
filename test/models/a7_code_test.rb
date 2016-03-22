require 'test_helper'
class A7CodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    a7 = A7Code.new
    assert_nil a7.code
    assert_nil a7.label
    assert a7.active 
    assert a7.master
    assert_nil a7.mapping
  end

  test 'check fixture' do
    a7 = a7_codes( :one )
    refute_nil a7.code
    refute_nil a7.label
    assert a7.active
    assert a7.master
    refute_nil a7.mapping
    assert a7.valid?
  end

  test 'code syntax' do
    a7 = a7_codes( :one )

    a7.code = ''
    refute a7.valid?
    assert_includes a7.errors, :code

    a7.code = ' '
    refute a7.valid?
    assert_includes a7.errors, :code

    a7.code = 'abc'
    refute a7.valid?
    assert_includes a7.errors, :code

    a7.code = '1'
    refute a7.valid?
    assert_includes a7.errors, :code

    a7.code = '?'
    refute a7.valid?
    assert_includes a7.errors, :code

    a7.code = 'ABCD'
    refute a7.valid?
    assert_includes a7.errors, :code
  end

  test 'code and label' do
    a7 = a7_codes( :one )
    a7.code = 'ABC'
    a7.label = 'Test'
    assert a7.valid?
    assert_equal 'ABC - Test', a7.code_and_label
  end

  test 'only one master should exist' do
    a7 = a7_codes( :one )
    an = a7.dup
    refute an.valid?
    assert_includes an.errors, :base
    an.master = false
    assert an.valid?, a7.errors.messages
  end

end
