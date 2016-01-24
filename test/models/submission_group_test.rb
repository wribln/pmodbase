require 'test_helper'
class SubmissionGroupTest < ActiveSupport::TestCase

  test "default values of new record" do 
    s = SubmissionGroup.new
    assert_nil s.code
    assert_nil s.label
  end

  test "required parameters: here it is code only" do
    s = SubmissionGroup.new
    assert s.invalid?
    assert_includes s.errors, :code
    assert_equal 1, s.errors.count
  end

  test "submission code must be unique" do
    s = SubmissionGroup.new
    s.code = submission_groups( :sub_group_one ).code
    assert s.invalid?
    assert_includes s.errors, :code
    assert_equal 1, s.errors.count
    s.code = s.code << 'a'
    assert s.valid?
    assert_difference('SubmissionGroup.count', +1) do
      s.save
    end
  end

  test "trimming of code" do
    s = SubmissionGroup.new
    s.code = "  a  code  "
    assert_equal s.code, "a code"
  end

  test "trimming of label" do 
    s = SubmissionGroup.new
    s.label = "  a  label  "
    assert_equal s.label, "a label"
  end

end
