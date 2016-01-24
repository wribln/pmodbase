require 'test_helper'
class SiemensPhaseTest < ActiveSupport::TestCase

  test "ensure defaults" do 
    sp = SiemensPhase.new
    assert_nil sp.code
    assert_nil sp.label_p
    assert_nil sp.label_m
  end

  test "ensure usefulness of test data" do
    sp = siemens_phases( :pm200 )
    assert_not sp.code.blank?, 'code must be present'
    assert MAX_LENGTH_OF_CODE > sp.code.length, 'length of code < max'
    assert_not sp.label_p.blank?, 'phase description must be present'
    assert MAX_LENGTH_OF_LABEL >= sp.label_p.length, 'length of label_p <= max'
    assert_not sp.label_m.blank?, 'milestone description must be present'
    assert MAX_LENGTH_OF_LABEL >= sp.label_m.length, 'length of label_m <= max'
  end

  test "required attributes" do
    sp = siemens_phases( :pm200 )
    assert sp.valid?
  end

  test "required attribute code" do
    sp = siemens_phases( :pm200 )
    sp.code = nil
    assert_not sp.valid?
    assert_includes sp.errors, :code
  end

  test "trimming of code" do
    sp = SiemensPhase.new
    sp.code = "  a  code  "
    assert_equal "a code", sp.code
  end

  test "trimming of label_p" do
    sp = SiemensPhase.new
    sp.label_p = "  a  label  "
    assert_equal "a label", sp.label_p
  end

  test "trimming of label_m" do
    sp = SiemensPhase.new
    sp.label_m = "  a  label  "
    assert_equal "a label", sp.label_m
  end

  test "uniqueness of code" do
    sp = siemens_phases( :pm200 )
    sp.id = nil
    assert_not sp.valid?
    assert_includes sp.errors, :code
  end

end
