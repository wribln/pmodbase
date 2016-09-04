require 'test_helper'
class GlossaryItemTest < ActiveSupport::TestCase

  test 'ensure fixture usefulness ' do
    gi = glossary_items( :one )
    assert gi.term.length <= MAX_LENGTH_OF_LABEL
    assert gi.code.length <= MAX_LENGTH_OF_CODE
    assert gi.cfr_record.present?
    assert gi.valid?
  end

  test 'ensure defaults' do
    gi = GlossaryItem.new
    assert_nil gi.term
    assert_nil gi.code
    assert_nil gi.description
    assert_nil gi.cfr_record
  end

  test 'required attributes' do 
    gi = glossary_items( :one )
    gi.code = nil
    assert gi.valid?
    gi.cfr_record_id = nil
    assert gi.valid?
    gi.term = nil 
    assert_not gi.valid?
  end

  test 'trimming of term' do
    gi = GlossaryItem.new
    gi.term = '  a  term  '
    assert_equal 'a term', gi.term
  end

  test 'trimming term to nil' do
    gi = GlossaryItem.new
    gi.term = '   '
    assert_nil gi.term
  end

  test 'trimming of code' do
    gi = GlossaryItem.new
    gi.code = '  a  code  '
    assert_equal 'a code', gi.code
  end

  test 'trimming code to nil' do
    gi = GlossaryItem.new
    gi.code = '   '
    assert_nil gi.code
  end

  test 'reference must exist' do
    gi = glossary_items( :one )
    gi.cfr_record_id = 0
    assert_not gi.valid?
    assert_includes gi.errors, :cfr_record_id
  end

end
