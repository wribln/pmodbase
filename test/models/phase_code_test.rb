require 'test_helper'
class PhaseCodeTest < ActiveSupport::TestCase

  test 'ensure defaults' do 
    pc = PhaseCode.new
    assert_nil pc.code
    assert_nil pc.label
    assert_nil pc.acro 
    assert_nil pc.siemens_phase_id
    assert_equal 0, pc.level
  end

  test 'ensure usefulness of test data' do 
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

  test 'given siemens phase exists' do
    pc = phase_codes( :prl )
    pc.siemens_phase_id = nil
    assert_not pc.valid?
    assert_includes pc.errors, :siemens_phase_id

    pc.siemens_phase_id = 0
    assert_not pc.valid?
    assert_includes pc.errors, :siemens_phase_id
  end

  test 'required attributes' do
    pc = phase_codes( :prl )
    assert pc.valid?
  end

  test 'required attribute code' do
    pc = phase_codes( :prl )
    pc.code = nil 
    assert_not pc.valid?
  end

  test 'required attribute label' do
    pc = phase_codes( :prl )
    pc.label = nil
    assert_not pc.valid?
  end

  test 'uniqueness of code' do
    pc = phase_codes( :prl ).dup
    refute pc.valid?
    assert_includes pc.errors, :code
  end

  test 'trimming of code' do
    pc = PhaseCode.new
    pc.code = '  a  code  '
    assert_equal 'a code', pc.code
  end

  test 'trimming of label' do
    pc = PhaseCode.new
    pc.label = '  a  label  '
    assert_equal 'a label', pc.label
  end

  test 'trimming of acro' do
    pc = PhaseCode.new
    pc.acro = '  an  acronym  '
    assert_equal 'an acronym', pc.acro
  end

  test 'acro <> code' do
    pc = phase_codes( :prl ).dup
    pc.acro = pc.code
    refute pc.valid?
    assert_includes pc.errors, :acro
  end

  test 'uniqueness of acro' do
    pc = phase_codes( :prl ).dup
    pc.code += 'X'
    refute pc.acro.blank?
    refute pc.valid?
    pc.acro += 'X'
    assert pc.valid?
    pc.acro = nil
    assert pc.valid?
  end

  test 'code syntax' do
    xc = phase_codes( :prl )
    
    xc.code = ''
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = ' '
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '%'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '%a'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '%?'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '%A-Za'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '%A-Z0-9.'
    assert xc.valid?

    xc.code = '%!'
    assert xc.valid?

  end

  test 'code and label' do
    xc = phase_codes( :prl )
    xc.code = '%NEW'
    xc.label = 'Test'
    assert xc.valid?
    assert_equal '%NEW - Test', xc.code_and_label
  end

end
