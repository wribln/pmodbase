require 'test_helper'
class SirEntryTest < ActiveSupport::TestCase

  test 'fixture' do
    se = sir_entries( :one )
    assert_equal 0, se.sir_item.validate_entries
    assert_equal 0, se.rec_type
    assert_equal se.resp_group_id, groups( :group_two ).id
    assert_equal se.orig_group_id, groups( :group_one ).id
    refute_nil se.description
    assert se.valid?, se.errors.messages
  end

  test 'required attributes and validation' do
    se = SirEntry.new
    refute se.valid?

    # must relate to SIR Item

    assert_includes se.errors, :sir_item_id
    si = sir_items( :one )
    se.sir_item = si

    # initial entry is forward from item owner (:group_one)
    # now the responsible group is :group_two

    assert_equal se.sir_item.resp_group, groups( :group_two )

    # need responsible group

    refute se.valid?
    assert_includes se.errors, :resp_group_id
    se.resp_group_id = groups( :group_two ).id

    # need originator group

    refute se.valid?
    assert_includes se.errors, :orig_group_id
    se.orig_group_id = groups( :group_one ).id

    # need record type

    refute se.valid?
    assert_includes se.errors, :rec_type
    se.rec_type = 0

    # test logic errors
    #
    #       responsible           originator  

    gs = [ groups( :group_two ).id, groups( :group_one ).id ] # current setting
    
    # logic error: originator is not currently responsible

    refute se.valid?
    assert_includes se.errors.messages, :orig_group_id

    # switch groups and try again

    se.orig_group_id, se.resp_group_id = gs

    # fails: forward to group_one not permitted (already in thread)

    refute se.valid?
    assert_includes se.errors, :base

    # try comment - fails as originator (here: resp_group_id) not currently responsible

    se.rec_type = 1
    refute se.valid?
    assert_includes se.errors, :resp_group_id

    # switch groups and try again

    se.resp_group_id, se.orig_group_id = gs
    assert se.valid?

    # set both groups to wrong group

    se.resp_group_id = se.orig_group_id
    refute se.valid?
    assert_includes se.errors, :resp_group_id

    # last test for forward / first test for response - to same group

    se.rec_type = 0
    refute se.valid?
    assert_includes se.errors, :base

    se.rec_type = 2
    refute se.valid?
    assert_includes se.errors, :base

    # reset to invalid combination

    se.resp_group_id, se.orig_group_id = gs
    refute se.valid?
    assert_includes se.errors, :orig_group_id

    # fix it for final, ok case

    se.orig_group_id, se.resp_group_id = gs
    assert se.valid?

    # save to continue with SIR Item owner

    assert se.save
    si.reload

    # attempt to create response by item owner

    se = si.sir_entries.new( rec_type: 2, resp_group: groups( :group_two ), orig_group: groups( :group_one ))
    refute se.valid?
    assert_includes se.errors, :base

    # comment should fail as originator (resp_group) is not currently responsible

    se.rec_type = 1
    refute se.valid?
    assert_includes se.errors, :resp_group_id

    # switch groups and try again

    se.resp_group_id, se.orig_group_id = se.orig_group_id, se.resp_group_id
    assert se.valid?, se.errors.messages
  end

  test 'defined scopes' do
    se2 = sir_items( :one ).sir_entries.create( id: 2, rec_type: 2, 
      resp_group_id: groups( :group_one ).id, 
      orig_group_id: groups( :group_two ).id, description: 'response' )

    se = SirEntry.all.log_order
    assert se[ 0 ].id = sir_entries( :one ).id
    assert se[ 1 ].id = se2.id
  end

  test 'is destroyable' do
    se1 = sir_entries( :one )
    si = se1.sir_item
    se2, se3, se4 = nil
    assert_difference( 'SirEntry.count', 3 ) do
      se2 = si.sir_entries.create( rec_type: 1, 
        resp_group_id: se1.resp_group_id, description: 'commment 1' )
      se3 = si.sir_entries.create( rec_type: 2,
        orig_group_id: se2.resp_group_id,
        resp_group_id: groups( :group_one ).id, description: 'response' )
      se4 = si.sir_entries.create( rec_type: 1, 
        resp_group_id: groups( :group_one ).id, description: 'comment 2' )
    end

    assert_equal 4, se1.sir_item.sir_entries.count

    assert_no_difference( 'SirEntry.count' ) do
      # assert_throws :abort do
      #   se3.destroy
      # end
      refute se3.destroy
    end
    assert_includes se3.errors, :base

    assert_difference( 'SirEntry.count', -1 ) do
      se2.destroy
    end
    si.reload

    assert_no_difference( 'SirEntry.count' ) do
      # assert_throws :abort do
      #   se3.destroy
      # end
      refute se3.destroy
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

  test 'default resp group' do
    se1 = sir_entries( :one )
    si = se1.sir_item
    se2 = si.sir_entries.new( rec_type: 1, resp_group_id: se1.resp_group_id )
    assert se2.valid?, se2.errors.messages
    se2.save
    assert_equal se2.resp_group_id, se2.orig_group_id

    se3 = si.sir_entries.new( rec_type: 0, orig_group_id: se2.resp_group_id )
    refute se3.valid?
    assert_includes se3.errors, :resp_group_id
    se3.rec_type = 2
    refute se3.valid?
    assert_includes se3.errors, :resp_group_id

  end


end
