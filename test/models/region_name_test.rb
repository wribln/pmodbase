require 'test_helper'
class RegionNameTest < ActiveSupport::TestCase

  test "fixture usefullness" do
    # code must be less than max
    rn = region_names( :mvp )
    assert rn.code.length < MAX_LENGTH_OF_CODE
    assert rn.label.length <= MAX_LENGTH_OF_LABEL    
  end

  test "default values of new record" do
    rn = RegionName.new
    assert_nil rn.code
    assert_nil rn.label
    assert_nil rn.country_name_id
  end

  test "given country exists" do
    rn = region_names( :mvp )
    rn.country_name_id = nil
    assert_not rn.valid?
    assert_includes rn.errors, :country_name_id

    rn.errors.clear
    rn.country_name_id = 0
    assert_not rn.valid?
    assert_includes rn.errors, :country_name_id
  end  

  test "required paramters: code only" do
    rn = RegionName.new
    assert_not rn.save
    rn.code = region_names( :mvp ).code << 'a'
    assert_not rn.save
    assert_includes rn.errors, :label
    assert_includes rn.errors, :country_name_id
  end

  test "required paramters: label only" do
    rn = RegionName.new
    assert_not rn.save
    rn.label = region_names( :mvp ).label
    assert_not rn.save
    assert_includes rn.errors, :code
    assert_includes rn.errors, :country_name_id
  end

  test "required parameters: country only" do
    rn = RegionName.new
    assert_not rn.save
    rn.country_name_id = region_names( :mvp ).country_name_id
    assert_not rn.save
    assert_includes rn.errors, :code
    assert_includes rn.errors, :label
  end

  test "all required paramters" do
    rn = RegionName.new
    r1 = region_names( :mvp )
    rn.code = r1.code << 'a'
    assert_not rn.valid?
    rn.label = r1.label
    assert_not rn.valid?
    rn.country_name_id = r1.country_name_id
    assert rn.valid?
  end

  test "trimming of code" do
    rn = RegionName.new
    rn.code = '  a  code  '
    assert_equal 'a code', rn.code
  end

  test "trimming of label" do
    rn = RegionName.new
    rn.label = '  a  label  '
    assert_equal 'a label', rn.label
  end

  test "trimming of empty code" do
    rn = RegionName.new
    rn.code = '   '
    assert_nil rn.code
    assert_not rn.valid?
    assert_includes rn.errors, :code
  end

  test "trimming of empty label" do
    rn = RegionName.new
    rn.label = '   '
    assert_nil rn.label
    assert_not rn.valid?
    assert_includes rn.errors, :label
  end

  test "uniqueness of country / code combination" do
    rn = region_names( :mvp )
    rn.id = nil 
    assert_not rn.valid?
    assert_includes rn.errors, :code
    rn.country_name_id = country_names( :usa ).id
    assert rn.valid?
  end

end
