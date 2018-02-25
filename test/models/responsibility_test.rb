require 'test_helper'

class ResponsibilityTest < ActiveSupport::TestCase

  test 'defaults for new records' do
    r = Responsibility.new
    assert_nil r.description
    assert r.seqno.is_a?( Integer )
    assert_nil r.person_id
    assert_nil r.group_id
    refute r.valid?
    assert_includes r.errors, :description
    assert_includes r.errors, :group_id
  end

  test 'fixture 1' do
    r = responsibilities( :one )
    assert r.valid?
  end

  test 'fixture 2' do
    r = responsibilities( :two )
    assert r.valid?
  end

  test 'given person must exist' do
    r = responsibilities( :one )

    r.person_id = nil
    assert r.valid?

    r.person_id = 0
    refute r.valid?
    assert_includes r.errors, :person_id
  end

  test 'given group must exist' do
    r = responsibilities( :one )
    r.group_id = nil
    refute r.valid?
    assert_includes r.errors, :group_id

    r.group_id = 0
    refute r.valid?
    assert_includes r.errors, :group_id
  end

  test 'related records must exist' do
    assert_difference( 'Responsibility.count' ) do
      r = Responsibility.new
      refute r.save, 'save with defaults'
      r.person = people(:person_one)
      refute r.save, 'save with valid person_id'
      r.person_id = 0
      refute r.save, 'save with N.N.'
      r.person_id = nil 
      r.group = groups(:group_one)
      refute r.save, 'save with valid group_id'
      r.person_id = people(:person_one).id
      r.description = 'test'
      assert r.save, 'save a valid record'
    end
  end

  test 'related record does not exist - group' do
    assert_difference( 'Group.count' ) do
      @g = Group.new
      @g.code = 'x'
      @g.label = 'x'
      @g.group_category_id = group_categories( :group_category_one ).id
      assert @g.save
    end
    assert_difference( 'Group.count', -1 ) do
      @gid = @g.id
      assert_kind_of Integer, @gid
      assert @g.destroy
    end
    assert_difference( 'Responsibility.count', 0 ) do
      r = Responsibility.new
      r.group_id = @gid
      r.description = 'test'
      refute r.save, 'should fail as group does not exist (anymore)'
      assert_includes r.errors, :group_id
    end
  end

  test 'remove leading and trailing blanks in description' do
    r = responsibilities(:one)
    r.description = '  test  1  2  3  '
    assert_equal r.description, 'test 1 2 3'
    r.description = '      test  '
    assert_equal r.description, 'test'
  end

end
