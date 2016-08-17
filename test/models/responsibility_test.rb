require 'test_helper'

class ResponsibilityTest < ActiveSupport::TestCase

  test "defaults for new records" do
    r = Responsibility.new
    assert_equal r.description, "", 'description should be empty string'
    assert( r.seqno.is_a?( Fixnum ), 'sequence number should be numeric' )
    assert_equal r.person_id, 0, 'person_id should be 0 = N.N.'
    assert_nil r.group_id, 'group_id must be set for create'
    assert_not r.save, 'save with default values should fail'
  end

  test "given person must exist or be 0" do
    r = responsibilities( :one )
    r.person_id = nil
    assert_not r.valid?, 'person must not be nil'
    assert_includes r.errors, :person_id

    r.person_id = 0
    assert r.valid?, "person = 0 is acceptable"

    r.person_id = -1
    assert_not r.valid?
    assert_includes r.errors, :person_id
  end

  test "given group must exist" do
    r = responsibilities( :one )
    r.group_id = nil
    assert_not r.valid?
    assert_includes r.errors, :group_id

    r.group_id = 0
    assert_not r.valid?
    assert_includes r.errors, :group_id
  end

  test "related records must exist" do
    assert_difference( 'Responsibility.count' ) do
      r = Responsibility.new
      assert_not r.save, "save with defaults"
      r.person_id = people(:person_one).id
      assert_not r.save, "save with valid person_id"
      r.person_id = 0
      assert_not r.save, "save with N.N."
      r.person_id = nil 
      r.group_id = groups(:group_one).id
      assert_not r.save, "save with valid group_id"
      r.person_id = people(:person_one).id
      r.description = "test"
      assert r.save, "save a valid record"
    end
  end

  test "related record does not exist - group" do
    assert_difference( 'Group.count' ) do
      @g = Group.new
      @g.code = "x"
      @g.label = "x"
      @g.group_category_id = group_categories( :group_category_one ).id
      assert @g.save
    end
    assert_difference( 'Group.count', -1 ) do
      @gid = @g.id
      assert_kind_of Fixnum, @gid
      assert @g.destroy
    end
    assert_difference( 'Responsibility.count', 0 ) do
      r = Responsibility.new
      r.group_id = @gid
      r.description = "test"
      assert_not r.save, 'should fail as group does not exist (anymore)'
    end
  end

  test "remove leading and trailing blanks in description" do
    r = responsibilities(:one)
    r.description = '  test  1  2  3  '
    assert_equal r.description, 'test 1 2 3'
    r.description = '      test  '
    assert_equal r.description, 'test'
  end

end
