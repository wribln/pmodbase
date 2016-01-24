require 'test_helper'

class GroupCategoryTest < ActiveSupport::TestCase

  test "add new record - test defaults" do
    gc = GroupCategory.new
    assert_equal gc.label, ""
    assert_equal gc.seqno, 0
  end

  test "trim text" do
    gc = GroupCategory.new
    gc.label = "  Label with   Blanks   "
    assert_equal gc.label, "Label with Blanks"
  end    

end
