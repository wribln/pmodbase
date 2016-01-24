require 'test_helper'
class CountryNameTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    # code must be less than max
    cn = country_names( :ger )
    assert cn.code.length < MAX_LENGTH_OF_CODE
    assert cn.label.length <= MAX_LENGTH_OF_LABEL 
  end

  test "default values of new record" do
    cn = CountryName.new
    assert_nil cn.code
    assert_nil cn.label
  end

  test "required parameters: code only" do
    cn = CountryName.new
    assert_not cn.save
    cn.code = country_names( :ger ).code << 'a'
    assert_not cn.save
  end

  test "required parameters: label only" do
    cn = CountryName.new
    assert_not cn.save
    cn.label = country_names( :ger ).label
    assert_not cn.save
  end

  test "all required parameters" do
    cn = CountryName.new
    c1 = country_names( :ger )
    cn.code = c1.code << 'a'
    assert_not cn.valid?
    cn.label = c1.label
    assert cn.valid?
  end

  test "trimming of code" do
    cn = CountryName.new
    cn.code = '  a  code  '
    assert_equal 'a code', cn.code
  end

  test "trimming of empty code" do
    cn = CountryName.new
    cn.code = "  "
    assert_nil cn.code
    assert_not cn.valid?
    assert_includes cn.errors, :code
  end

  test "trimming of label" do
    cn = CountryName.new
    cn.label = '  a  label  '
    assert_equal 'a label', cn.label
  end

  test "trimming of empty label" do
    cn = CountryName.new
    cn.label = "  "
    assert_nil cn.label
    assert_not cn.valid?
    assert_includes cn.errors, :label
  end

  test "uniqueness of code" do
    cn = country_names( :ger )
    cn.id = nil
    assert_not cn.valid?
    assert_includes cn.errors, :code
  end

end
