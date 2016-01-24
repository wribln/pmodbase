require 'test_helper'
class StandardsBodyTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    sb = standards_bodies( :din )
    assert sb.code.length <= MAX_LENGTH_OF_CODE
    assert sb.description.length <= MAX_LENGTH_OF_DESCRIPTION
  end

  test "default values of new record" do
    sb = StandardsBody.new
    assert_nil sb.code
    assert_nil sb.description
  end

  test "required parameters: code only" do
    sb = StandardsBody.new
    assert_not sb.save
    sb.code = '123'
    assert_not sb.save
  end

  test "required parameters: description only" do
    sb = StandardsBody.new
    assert_not sb.save
    sb.description = 'one two three'
    assert_not sb.save
  end

  test "all required parameters" do
    sba = StandardsBody.new
    sbb = standards_bodies( :din )
    sba.code = sbb.code
    assert_not sba.valid?
    sba.description = sbb.description
    assert sba.valid?
  end

  test "trimming of code" do
    sb = StandardsBody.new
    sb.code = '  a  code  '
    assert_equal 'a code', sb.code
  end

  test "trimming of description" do
    sb = StandardsBody.new
    sb.description = '  a  description  '
    assert_equal 'a description', sb.description
  end
  
  test "trimming of empty code" do
    sb = StandardsBody.new
    sb.code = '   '
    assert_nil sb.code
    assert_not sb.valid?
    assert_includes sb.errors, :code
  end

  test "trimming of empty description" do
    sb = StandardsBody.new
    sb.description = '   '
    assert_nil sb.description
    assert_not sb.valid?
    assert_includes sb.errors, :description
  end

end
