require 'test_helper'
class PermissionForUserTest < ActiveSupport::TestCase

  # check fixture configuration

  setup do
    @a = accounts( :wop )
  end

  # test robustness

  test "non-existing feature" do
    assert_not @a.permission_to_index?( 0 )
    assert_nil @a.permitted_groups( 0 )
    assert_equal false, @a.permission_to_access( 0, :to_index, 0 )
  end

  # test access control

  test "no permission record: nothing permitted" do
    assert @a.active
    assert_not @a.permission4_groups.exists?

    Feature.all.each do |f|
      assert_not @a.permission_to_index?( f.id )
      assert_nil @a.permitted_groups( f.id )
      [ :to_index, :to_create, :to_read, :to_update, :to_delete ].each do |to_x|
        assert_nil @a.permitted_groups( f.id, to_x )
        assert_equal false, @a.permission_to_access( f.id, to_x, 0 )
        Group.all.each do |g|
          assert_equal false, @a.permission_to_access( f.id, to_x, g.id )
        end
      end
    end
  end

  test "permit to index feature 1 for all groups" do
    @p = @a.permission4_groups.new
    @p.feature_id = features( :feature_one ).id
    @p.group_id = 0
    @p.to_index = 1
    assert @p.save

    f1 = features( :feature_one ).id
    f2 = features( :feature_two ).id

    assert @a.permission_to_index?( f1 )
    assert_not @a.permission_to_index?( f2 )

    assert_empty @a.permitted_groups( f1 )
    assert_nil @a.permitted_groups( f2 )

    [ :to_index ].each do |to_x|
      assert_empty @a.permitted_groups( f1, to_x )
      assert_equal 1, @a.permission_to_access( f1, to_x )
      assert_nil @a.permitted_groups( f2, to_x )
      assert_equal false, @a.permission_to_access( f2, to_x )
      Group.all.each do |g|
        assert @a.permission_to_access( f1, to_x, g.id )
        assert_equal false, @a.permission_to_access( f2, to_x, g.id )
      end
    end

    [ :to_create, :to_read, :to_update, :to_delete ].each do |to_x|
      assert_nil @a.permitted_groups( f1, to_x )
      assert_nil @a.permitted_groups( f2, to_x )
      assert_equal false, @a.permission_to_access( f1, to_x, 0 )
      assert_equal false, @a.permission_to_access( f2, to_x, 0 )
      Group.all.each do |g|
        assert_equal false, @a.permission_to_access( f1, to_x, g.id )
        assert_equal false, @a.permission_to_access( f2, to_x, g.id )
      end
    end
  end

  test "permit to index feature 2 for all groups" do
    @p = @a.permission4_groups.new
    @p.feature_id = features( :feature_one ).id
    @p.group_id = 0
    @p.to_index = 2
    assert @p.save

    f1 = features( :feature_one ).id
    f2 = features( :feature_two ).id

    assert @a.permission_to_index?( f1 )
    assert_not @a.permission_to_index?( f2 )

    assert_empty @a.permitted_groups( f1 )
    assert_nil @a.permitted_groups( f2 )

    [ :to_index ].each do |to_x|
      assert_empty @a.permitted_groups( f1, to_x )
      assert_equal 2, @a.permission_to_access( f1, to_x )
      assert_nil @a.permitted_groups( f2, to_x )
      assert_equal false, @a.permission_to_access( f2, to_x )
      Group.all.each do |g|
        assert @a.permission_to_access( f1, to_x, g.id )
        assert_equal false, @a.permission_to_access( f2, to_x, g.id )
      end
    end

    [ :to_create, :to_read, :to_update, :to_delete ].each do |to_x|
      assert_nil @a.permitted_groups( f1, to_x )
      assert_nil @a.permitted_groups( f2, to_x )
      assert_equal false, @a.permission_to_access( f1, to_x, 0 )
      assert_equal false, @a.permission_to_access( f2, to_x, 0 )
      Group.all.each do |g|
        assert_equal false, @a.permission_to_access( f1, to_x, g.id )
        assert_equal false, @a.permission_to_access( f2, to_x, g.id )
      end
    end
  end

end