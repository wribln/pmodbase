require 'test_helper'
class PhaseCodeTest < ActiveSupport::TestCase

  test "ensure defaults" do 
    pc = PhaseCode.new
    assert_nil pc.code
    assert_nil pc.label
    assert_nil pc.acro 
    assert_nil pc.siemens_phase_id
    assert_equal 0, pc.level
  end

  test "ensure usefulness of test data" do 
    pc = phase_codes( :prl )
    # code must be set
    assert_not pc.code.blank?
    # code must allow for one more character
    assert MAX_LENGTH_OF_CODE > pc.code.length

    # acronym must be set
    assert_not pc.acro.blank?
    # acronym must allow one more character
    assert MAX_LENGTH_OF_CODE > pc.acro.length

    # siemens_phase must be present
    assert_not pc.siemens_phase_id.blank?
  end

  test "given siemens phase exists" do
    pc = phase_codes( :prl )
    pc.siemens_phase_id = nil
    assert_not pc.valid?
    assert_includes pc.errors, :siemens_phase_id

    pc.siemens_phase_id = 0
    assert_not pc.valid?
    assert_includes pc.errors, :siemens_phase_id
  end

  test "required attributes" do
    pc = phase_codes( :prl )
    assert pc.valid?
  end

  test "required attribute code" do
    pc = phase_codes( :prl )
    pc.code = nil 
    assert_not pc.valid?
  end

  test "required attribute label" do
    pc = phase_codes( :prl )
    pc.label = nil
    assert_not pc.valid?
  end

  test "uniqueness of code" do
    pc = phase_codes( :prl )
    pc.id = nil
    assert_not pc.valid?
    assert_includes pc.errors, :code
  end

  test "trimming of code" do
    pc = PhaseCode.new
    pc.code = "  a  code  "
    assert_equal "a code", pc.code
  end

  test "trimming of label" do
    pc = PhaseCode.new
    pc.label = "  a  label  "
    assert_equal "a label", pc.label
  end

  test "trimming of acro" do
    pc = PhaseCode.new
    pc.acro = "  an  acronym  "
    assert_equal "an acronym", pc.acro
  end

  test "acro <> code" do
    pc = phase_codes( :prl )
    pc.id = nil
    pc.acro = pc.code
    assert_not pc.valid?
    assert_includes pc.errors, :acro
  end

  test "uniqueness of acro" do
    pc = phase_codes( :prl )
    pc.id = nil
    pc.code += 'a'
    assert_not pc.acro.blank?
    assert_not pc.valid?
    pc.acro += 'a'
    assert pc.valid?
    pc.acro = nil
    assert pc.valid?
  end
end
