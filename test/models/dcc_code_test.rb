require 'test_helper'
class DccCodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    assert_equal '&', DccCode.code_prefix
    xc = DccCode.new
    assert_nil xc.code 
    assert_nil xc.label
    assert xc.active 
    assert xc.master 
    assert xc.standard 
    refute xc.heading
  end

  test 'ensure fixture 1 settings' do
    xc = dcc_codes( :one )
    refute_nil xc.code
    refute_nil xc.label
    assert xc.active
    assert xc.master
    assert xc.standard
    refute xc.heading
    assert xc.valid?,xc.errors.messages
  end

  test 'ensure fixture 2 settings' do
    xd = DccCode.new
    xc = dcc_codes( :two )
    refute_nil xc.code
    refute_nil xc.label
    assert_equal xc.active, xd.active
    assert_equal xc.master, xd.master
    assert_equal xc.standard, xd.standard
    assert_equal xc.heading, xd.heading
    assert xc.valid?,xc.errors.messages
  end

  test 'has_code_prefix' do
    assert DccCode.has_code_prefix( '&AB' )
    refute DccCode.has_code_prefix( 'BA&' )
    refute DccCode.has_code_prefix( '' )
    refute DccCode.has_code_prefix( 'ABC' )
    assert DccCode.has_code_prefix( '&&&' )
  end

  test 'code syntax' do
    xc = dcc_codes( :two )
    
    xc.code = ''
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = ' '
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '&'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '&a'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '&?'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '&A-Za'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '&A-Z0-9.'
    assert xc.valid?
  end

  test 'code and label' do
    xc = dcc_codes( :two )
    xc.code = '&ABC'
    xc.label = 'Test'
    assert_equal '&ABC - Test', xc.code_and_label
  end

  test 'flag combinations' do

    xc = dcc_codes( :one )

    # standard value has no interaction to others

    [ true, false ].each do |std|

      xc.active = true
      xc.heading = true
      xc.master = true
      xc.standard = std

      # 111x - active, heading, master, standard
      refute xc.valid?
      assert_includes xc.errors, :heading
      assert_equal xc.errors.count, 2
      # heading cannot be master, heading must not be active

      # 011x - !active, heading, master standard
      xc.active = false
      refute xc.valid?
      assert_includes xc.errors, :heading
      assert_equal xc.errors.count, 1
      # heading cannot be master

      # 101x - active, !heading, master, standard
      xc.active = true
      xc.heading = false
      assert xc.valid?

      # 001x - !active, !heading, master, standard
      xc.active = false
      assert xc.valid?

      # 110x - active, heading, !master, standard
      xc.active = true
      xc.heading = true
      xc.master = false
      refute xc.valid?
      assert_includes xc.errors, :heading
      assert_equal xc.errors.count, 1
      # heading must not be active

      # 010x - !active, heading, !master, standard
      xc.active = false
      assert xc.valid?, xc.errors.messages

      # 100x - active, !heading, !master, standard
      xc.active = true
      xc.heading = false
      assert xc.valid?, xc.errors.messages

      # 000x - !active, !heading, !master, standard
      xc.active = false
      assert xc.valid?, xc.errors.messages
  
    end

  end

  test 'only one master should exist' do
    xc = dcc_codes( :one )
    xn = xc.dup
    refute xn.valid?
    assert_includes xn.errors, :base
    xn.master = false
    assert xn.valid?, xc.errors.messages
  end

end
