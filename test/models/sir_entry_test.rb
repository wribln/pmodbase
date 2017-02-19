require 'test_helper'
class SirEntryTest < ActiveSupport::TestCase

  test 'fixture' do
    se = sir_entries( :one )
    assert_equal 0, se.sir_item.validate_entries
    assert_equal 0, se.rec_type
    assert_equal se.group_id, groups( :group_two ).id
    refute_nil se.description
    refute se.is_public
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

    se = SirEntry.all.rev_order
    assert se[ 0 ].id = se2.id
    assert se[ 1 ].id = sir_entries( :one ).id
  end

  test 'is destroyable' do
    se1 = sir_entries( :one )
    assert se1.destroyable?

    se2 = nil
    assert_difference( 'SirEntry.count', 1 ) do
      se2 = sir_items( :one ).sir_entries.create( rec_type: 1, group_id: se1.group_id, description: 'commment 1' )
    end
    assert se2.destroyable?
    refute se1.destroyable?

    se3 = nil
    assert_difference( 'SirEntry.count', 1 ) do
      se3 = sir_items( :one ).sir_entries.create( rec_type: 2, group_id: groups( :group_one ).id, description: 'response' )
    end
    assert se3.destroyable?
    assert se2.destroyable?
    refute se1.destroyable?

    se4 = nil
    assert_difference( 'SirEntry.count', 1 ) do
      se4 = sir_items( :one ).sir_entries.create( rec_type: 1, group_id: groups( :group_one ).id, description: 'comment 2' )
    end
    assert se4.destroyable?
    refute se3.destroyable?
    assert se2.destroyable?
    refute se1.destroyable?

    se4.destroy 
    assert se3.destroyable?
    assert se2.destroyable?
    refute se1.destroyable?
  end

end
