require 'test_helper'
class GlossaryItemTest < ActiveSupport::TestCase

  test "ensure fixture usefulness " do
    gi = glossary_items( :one )
    assert gi.term.length <= MAX_LENGTH_OF_LABEL
    assert gi.code.length <= MAX_LENGTH_OF_CODE
    assert gi.reference.present?
    assert gi.valid?
  end

  test "ensure defaults" do
    gi = GlossaryItem.new
    assert_nil gi.term
    assert_nil gi.code
    assert_nil gi.description
    assert_nil gi.reference
  end

  test "required attributes" do 
    gi = glossary_items( :one )
    gi.code = nil
    assert gi.valid?
    gi.reference = nil
    assert gi.valid?
    gi.term = nil 
    assert_not gi.valid?
  end

  test "trimming of term" do
    gi = GlossaryItem.new
    gi.term = "  a  term  "
    assert_equal 'a term', gi.term
  end

  test "trimming term to nil" do
    gi = GlossaryItem.new
    gi.term = "   "
    assert_nil gi.term
  end

  test "trimming of code" do
    gi = GlossaryItem.new
    gi.code = "  a  code  "
    assert_equal 'a code', gi.code
  end

  test "trimming code to nil" do
    gi = GlossaryItem.new
    gi.code = "   "
    assert_nil gi.code
  end

  test "reference must exist" do
    gi = glossary_items( :one )
    gi.reference_id = 0
    assert_not gi.valid?
    assert_includes gi.errors, :reference_id
  end

  test "reference with id" do
    gi = glossary_items( :one )
    r = references( :one )
    assert_equal gi.reference_with_id, "#{ r.code } [#{ r.id }]"
  end

end
