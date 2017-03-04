require 'test_helper'
class SirEntryTest < ActiveSupport::TestCase

  test 'fixture' do
    se = sir_entries( :one )
    assert_equal 0, se.sir_item.validate_entries
    assert_equal 0, se.rec_type
    assert_equal se.group_id, groups( :group_two ).id
    refute_nil se.description
    assert se.valid?, se.errors.messages
  end

  test 'required attributes' do
    se = SirEntry.new
    refute se.valid?

    assert_includes se.errors, :sir_item_id
    se.sir_item = sir_items( :one )
    refute se.valid?

    assert_includes se.errors, :group_id
    se.group_id = groups( :group_two ).id
    refute se.valid?

    assert_includes se.errors, :rec_type
    se.rec_type = 1
    assert se.valid?, se.errors.messages
  end

  test 'defined scopes' do
    se2 = sir_items( :one ).sir_entries.create( id: 2, rec_type: 2, group_id: groups( :group_one ).id, description: 'response' )

    se = SirEntry.all.log_order
    assert se[ 0 ].id = sir_entries( :one ).id
    assert se[ 1 ].id = se2.id
  end

  test 'is destroyable' do
    se1 = sir_entries( :one )
    si = se1.sir_item
    se2, se3, se4 = nil
    assert_difference( 'SirEntry.count', 3 ) do
      se2 = si.sir_entries.create( rec_type: 1, group_id: se1.group_id, description: 'commment 1' )
      se3 = si.sir_entries.create( rec_type: 2, group_id: groups( :group_one ).id, description: 'response' )
      se4 = si.sir_entries.create( rec_type: 1, group_id: groups( :group_one ).id, description: 'comment 2' )
    end

    assert_equal 4, se1.sir_item.sir_entries.count

    assert_no_difference( 'SirEntry.count' ) do
      assert_throws :abort do
        se3.destroy
      end
    end
    assert_includes se3.errors, :base

    assert_difference( 'SirEntry.count', -1 ) do
      se2.destroy
    end
    si.reload

    assert_no_difference( 'SirEntry.count' ) do
      assert_throws :abort do
        se3.destroy
      end
    end
    assert_includes se3.errors, :base

    assert_difference( 'SirEntry.count', -2 ) do
      se4.destroy
      si.reload
      se3.destroy
    end

  end

  test 'visibility' do
    se = sir_entries( :one )
    assert se.visibility.nil?
    refute se.is_visible?

    se.visibility = 0
    refute se.is_visible?

    se.visibility = 1
    assert se.is_visible?
  end

end
