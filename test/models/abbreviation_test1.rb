require 'test_helper'
class AbbreviationTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    a = abbreviations( :sag )
    assert a.code.length <= MAX_LENGTH_OF_CODE
    assert a.description.length <= MAX_LENGTH_OF_DESCRIPTION
  end

  test "default values of new record" do
    a = Abbreviation.new
    assert_nil a.code
    assert_nil a.description
  end

  test "required parameters: code only" do
    a = Abbreviation.new
    assert_not a.save
    a.code = '123'
    assert_not a.save
  end

  test "required parameters: description only" do
    a = Abbreviation.new
    assert_not a.save
    a.description = 'one two three'
    assert_not a.save
  end

  test "all required parameters" do
    a = Abbreviation.new
    b = abbreviations( :sag )
    a.code = b.code
    assert_not a.valid?
    a.description = b.description
    assert a.valid?
  end

  test "trimming of code" do
    a = Abbreviation.new
    a.code = '  a  code  '
    assert_equal 'a code', a.code
  end

  test "trimming of description" do
    a = Abbreviation.new
    a.description = '  a  description  '
    assert_equal 'a description', a.description
  end

  test "code must not be unique" do
    a = abbreviations( :sag )
    b = Abbreviation.new
    b.code = a.code
    b.description = a.description
    assert b.valid?
    assert_difference( 'Abbreviation.count' ) do
      b.save
    end
  end   

end
