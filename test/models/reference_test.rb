require 'test_helper'
class ReferenceTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    ref = references( :one )
    assert ref.code.length < MAX_LENGTH_OF_CODE
    assert ref.description.length <= MAX_LENGTH_OF_DESCRIPTION
    assert ref.project_doc_id.length <= ProjectDocLog::MAX_LENGTH_OF_DOC_ID
  end

  test "default values of new record" do
    ref = Reference.new
    assert_nil ref.code
    assert_nil ref.description
    assert_nil ref.project_doc_id
  end

  test "trimming of code" do
    ref = Reference.new
    ref.code = '  a  code  '
    assert_equal 'a code', ref.code
  end

  test "validity of Reference" do
    ref = Reference.new
    assert_not ref.valid?
    assert_includes ref.errors, :code
    ref.code = 'x'
    assert ref.valid?
  end

  test "uniqueness of code" do
    ref = references( :one )
    assert ref.valid?
    ref.id = nil 
    assert_not ref.valid?
    assert_includes ref.errors, :code
  end

end
