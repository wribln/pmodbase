require 'test_helper'
class GroupTest < ActiveSupport::TestCase

  test "default values of new record" do
    g = Group.new
    assert_equal g.code, ""
    assert_equal g.label, ""
    assert_equal g.seqno, 0
    assert_nil g.notes
    assert_nil g.group_category_id
  end

  test "required parameters: code only" do
    g = Group.new
    assert_not g.valid?
    g.code = groups( :group_one ).code
    assert_not g.valid?
    g.code = ""
    assert_not g.valid?
  end

  test "required parameters: label only" do
    g = Group.new
    g.label = groups( :group_one ).label
    assert_not g.valid?
    g.label = ""
    assert_not g.valid?
  end

  test "required parameters: category only" do
    g = Group.new
    g.group_category_id = groups( :group_one ).group_category_id
    assert_not g.valid?
    g.group_category_id = nil
    assert_not g.valid?
  end

  test "required parameters: notes only" do
    g = Group.new
    g.notes = "Test Note"
    assert_not g.valid?
    g.notes = ""
    assert_not g.valid?
  end

  test "required parameters: seqno only" do
    g = Group.new
    g.seqno = 1
    assert_not g.valid?
    g.seqno = nil
    assert_not g.valid?
  end

  test "required parameters: all required" do
    g = Group.new
    t = groups( :group_one )
    g.code = t.code << "a"
    assert_not g.valid?
    g.label = t.label
    assert_not g.valid?
    g.group_category_id = t.group_category_id
    assert g.valid?
  end
  
  test "method label_with_id" do
    g = groups( :group_one )
    assert_equal text_with_id( g.label, g.id ), g.label_with_id
  end

  test "method code_with_id" do
    g = groups( :group_one )
    assert_equal text_with_id( g.code, g.id ), g.code_with_id
  end

end
