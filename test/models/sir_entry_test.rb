require 'test_helper'
class SirEntryTest < ActiveSupport::TestCase

  test 'fixture 1' do
    se = sir_entries( :one )
    assert_equal 0, se.rec_type
    assert_equal se.group_id, groups( :group_two ).id
    assert_nil se.parent_id
    assert_equal 0, se.depth
    refute_nil se.description
    refute se.is_public
    assert se.valid?, se.errors.messages
  end

  test 'fixture 2' do 
    se = sir_entries( :two )
    assert_equal 2, se.rec_type
    assert_equal se.group_id, groups( :group_two ).id
    assert_equal se.parent_id, sir_entries( :one ).id
    assert_equal 0, se.depth
    refute_nil se.description
    refute se.is_public
    assert se.valid?, se.errors.messages
  end

  test 'add response w/o request' do
    se = sir_items( :one ).sir_entries.new
    se.rec_type = 2
    se.group_id = groups( :group_two ).id
    se.parent_id = nil
    refute se.valid?
    assert_includes se.errors, :parent_id
  end

  test 'refer to non-existing parent' do
    sir_entries( :one ).destroy
    se = sir_entries( :two )
    refute se.valid?
    assert_includes se.errors, :parent_id
  end

  test 'refer to parent outside of this item' do
    si = sir_items( :two )
    se = sir_entries( :two )
    se.parent = se
    refute se.valid?
    assert_includes se.errors, :parent_id
  end

  test 'required attributes' do
    se = SirEntry.new
    refute se.valid?

    assert_includes se.errors, :sir_item_id
    se.sir_item = sir_items( :one )
    refute se.valid?

    assert_includes se.errors, :group_id
    se.group_id = groups( :group_two ).id
    assert se.valid?, se.errors.messages
  end

  test 'try to create bad reference - comment' do
    si = sir_items( :one )

    se  = si.sir_entries.build( rec_type: 1, group: groups( :group_two ))
    refute se.valid?
    assert_includes se.errors.messages, :group_id

    se.group = groups( :group_one )
    assert se.valid?

    se.parent = sir_entries( :one )
    refute se.valid?
    assert_includes se.errors.messages, :group_id

    se.parent = sir_entries( :two )    
    refute se.valid?
    assert_includes se.errors.messages, :group_id

    se.group = groups( :group_two )
    assert se.valid?, se.errors.messages
  end

  test 'try to create bad reference - request' do
    si = sir_items( :one )

    se  = si.sir_entries.build( rec_type: 0, group: groups( :group_one ))
    refute se.valid?
    assert_includes se.errors.messages, :group_id
  end

  test 'defined scopes' do
    se = SirEntry.all.log_order
    assert se[ 0 ].id = sir_entries( :one ).id
    assert se[ 1 ].id = sir_entries( :two ).id
  end

  test 'is leaf' do
    refute sir_entries( :one ).is_leaf?
    assert sir_entries( :two ).is_leaf?
  end

end
