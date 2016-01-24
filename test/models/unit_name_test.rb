require 'test_helper'
class UnitNameTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    un = unit_names( :one )
    assert un.code.length <= MAX_LENGTH_OF_CODE
    assert un.label.length <= MAX_LENGTH_OF_DESCRIPTION
  end

  test "default values of new record" do
    un = UnitName.new
    assert_nil un.code
    assert_nil un.label
  end

  test "required parameters: code only" do
    un = UnitName.new
    assert_not un.save
    un.code = 'abc'
    assert_not un.save
  end

  test "required parameters: label only" do
    un = UnitName.new
    assert_not un.save
    un.label = 'one two three'
    assert_not un.save
  end

  test "all required parameters" do
    una = UnitName.new
    unb = unit_names( :one )
    una.code = unb.code
    assert_not una.valid?
    una.label = unb.label
    assert una.valid?
  end

  test "trimming of code" do
    un = UnitName.new
    un.code = '  a  code  '
    assert_equal 'a code', un.code
  end

  test "trimming of label" do
    un = UnitName.new
    un.label = '  a  label  '
    assert_equal 'a label', un.label
  end
  
  test "trimming of empty code" do
    un = UnitName.new
    un.code = '   '
    assert_nil un.code
    assert_not un.valid?
    assert_includes un.errors, :code
  end

  test "trimming of empty label" do
    un = UnitName.new
    un.label = '   '
    assert_nil un.label
    assert_not un.valid?
    assert_includes un.errors, :label
  end

  test "combination code and label" do
    un = UnitName.new
    un.code = "abc"
    un.label = "The Alphabet"
    assert_equal "abc (The Alphabet)", un.unit_name_and_label
  end

end
