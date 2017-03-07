require 'test_helper'
class SirItem1Test < ActiveSupport::TestCase

  test 'fixture 1' do 
    si = sir_items( :one )
    refute_nil si.sir_log_id
    refute_nil si.group_id
    assert_equal 1, si.seqno
    refute_nil si.reference
    refute_nil si.cfr_record_id
    assert_equal 1, si.status
    assert_equal 1, si.category
    refute_nil si.phase_code_id
    refute si.archived
    refute_nil si.description
    assert si.valid?
  end

  test 'fixture 2' do 
    si = sir_items( :two )
    refute_nil si.sir_log_id
    refute_nil si.group_id
    assert_equal 2, si.seqno
    assert_nil si.reference
    assert_nil si.cfr_record_id
    assert_equal 0, si.status
    assert_equal 1, si.category
    assert_nil si.phase_code_id
    refute si.archived
    refute_nil si.description
    assert si.valid?
  end

  test 'ensure status dimensions' do
    assert_equal 4, SirItem::SIR_ITEM_STATUS_LABELS.size
    assert_equal 'new', SirItem::SIR_ITEM_STATUS_LABELS[ 0 ]
    assert_equal 'open', SirItem::SIR_ITEM_STATUS_LABELS[ 1 ]
    assert_equal 'response accepted', SirItem::SIR_ITEM_STATUS_LABELS[ 2 ]
    assert_equal 'closed', SirItem::SIR_ITEM_STATUS_LABELS[ 3 ]
  end

  test 'status labels and status' do
    si = SirItem.new
    si.status = 0
    assert si.status_open?
    assert_equal 'new', si.status_label

    si.status = 2
    assert si.status_open?

    si.status = 3
    refute si.status_open?
  end

  test 'ensure category dimensions' do
    assert_equal 5, SirItem::SIR_ITEM_CATEGORY_LABELS.size
  end

  test 'required attributes' do
    si = SirItem.new
    refute si.valid?

    # sir_log_id

    assert_includes si.errors, :sir_log_id
    si.sir_log = sir_logs( :sir_log_one )
    refute si.valid?
    refute_includes si.errors, :sir_log_id

    # group_id

    assert_includes si.errors, :group_id
    si.group = groups( :group_two )
    refute si.valid?
    refute_includes si.errors, :group_id

    # label

    assert_includes si.errors, :label
    si.label = 'something'
    assert si.valid?, si.errors.messages
  end

  test 'seqno must be unique within this log' do
    si = sir_items( :one )
    sn = si 
    sn.id = nil 
    refute sn.valid?
    assert_includes sn.errors, :seqno
    sn.seqno = 2
    refute sn.valid?
    sn.seqno = 3
    assert sn.valid?
  end

  test 'sir log must exist' do
    si = sir_items( :one )
    assert_equal si.sir_log_id, sir_logs( :sir_log_one ).id
    sl_id = sir_logs( :sir_log_two ).id
    SirLog.find( sl_id ).destroy
    si.sir_log_id = sl_id
    refute si.valid?
    assert_includes si.errors, :sir_log_id
  end

  test 'do not archive unless item is closed' do
    si = sir_items( :one )
    si.archived = true

    si.status = 0
    assert si.status_open?
    assert si.invalid?
    assert_includes si.errors, :archived

    si.status = 1
    assert si.status_open?
    assert si.invalid?
    assert_includes si.errors, :archived

    si.status = 2
    assert si.status_open?
    assert si.invalid?
    assert_includes si.errors, :archived

    si.status = 3
    refute si.status_open?
    assert si.valid?
  end    

  test 'sir entries validation' do
    si = sir_logs( :sir_log_one ).sir_items.build( group_id: groups( :group_one ).id, label: 'test', seqno: 3 )
    assert si.save, si.errors.messages
    assert_equal 0, si.validate_entries

    se = si.sir_entries.build( rec_type: 0, 
      resp_group_id: groups( :group_one ).id, 
      orig_group_id: si.group_id, description: 'test 1' )
    assert_equal 0, si.validate_entries
    refute se.valid?
    assert_includes se.errors, :base # forward to itself

    se.rec_type = 2
    refute se.valid?
    assert_includes se.errors, :base # respond to item owner


    se.resp_group_id = groups( :group_two ).id
    refute se.valid?
    assert_includes se.errors, :base # respond to other group

    se.rec_type = 1
    assert se.valid?

    se.rec_type = 0
    assert se.save, se.errors.messages
    si.reload
    assert_equal 0, si.validate_entries

    # next entry

    se = si.sir_entries.build( rec_type: 0, 
      resp_group_id: groups( :group_one ).id, 
      orig_group_id: groups( :group_two ).id, description: 'test 2')
    assert_equal 0, si.validate_entries
    refute se.valid?
    assert_includes se.errors, :base # forward to item owner

    se.resp_group = groups( :group_two )
    refute se.valid?
    assert_includes se.errors, :base # forward to previous entry

    gp = Group.new( code: 'XXX', group_category_id: group_categories( :group_category_one ).id, label: 'XXX-Group' )
    assert gp.save, gp.errors.messages

    se.resp_group_id = gp.id
    assert se.valid?

    se.rec_type = 1
    assert se.valid?

    se.resp_group_id = groups( :group_two ).id
    assert se.valid?

    se.rec_type = 2
    refute se.valid?
    assert_includes se.errors, :base # respond to own group

    se.resp_group_id = gp.id
    refute se.valid?
    assert_includes se.errors, :resp_group_id # respond to other group

    se.resp_group_id = groups( :group_one ).id
    assert se.valid?

  end

  test 'scopes' do
    si = SirItem.ff_seqno( 1 )
    assert_equal si.count, 1

    si = SirItem.ff_ref( 'other' )
    assert_equal si.count, 1

    si = SirItem.ff_desc( 'item no')
    assert_equal si.count, 2

    si = SirItem.ff_stts( 0 )
    assert_equal si.count, 1

    si = SirItem.ff_stts( 1 )
    assert_equal si.count, 1

    si = SirItem.ff_stts( 2 )
    assert_equal si.count, 0

    si = SirItem.ff_cat( 1 )
    assert_equal si.count, 2

    si = SirItem.ff_phs( 0 )
    assert_equal si.count, 0
    si = SirItem.ff_phs( phase_codes( :prl ))
    assert_equal si.count, 1

    si = SirItem.ff_cgrp( groups( :group_one ))
    assert_equal si.count, 0, si.inspect

    si = SirItem.ff_cgrp( groups( :group_two ))
    assert_equal si.count, 2
  end

  test 'responsible group 1' do
    si = SirItem.new
    si.group = groups( :group_one )
    assert si.resp_group_code, groups( :group_one ).code

    si.group_id = 0
    assert si.resp_group_code, si.some_id( 0 )
  end

  test 'responsible group 2' do
    si = sir_items( :one )
    assert si.group_code, groups( :group_one ).code
    assert si.resp_group_code, groups( :group_two ).code
  end

  test 'update status on :one' do
    si = sir_items( :one )
    assert_equal 1, si.status
    assert_equal 1, si.sir_entries.count

    si.status = 0
    refute si.valid?
    assert_includes si.errors, :status

    si.status = 1
    assert si.valid?

    si.status = nil
    refute si.valid?
    assert_includes si.errors, :status
  end

  test 'update status on :two' do
    si = sir_items( :two )
    assert_equal 0, si.status
    assert_equal 0, si.sir_entries.count

    si.status = 1
    assert si.valid?

    si.status = 0
    assert si.valid?

    si.status = 1
    assert si.valid?

    si.status = nil
    refute si.valid?
    assert_includes si.errors, :status

  end

  test 'attempt to modify group on :one' do
    si = sir_items( :one )
    g1 = si.group_id
    g2 = groups( :group_two ).id
    refute_equal g1, g2
    assert si.valid?, si.errors.messages

    si.group_id = g2
    refute si.valid?
    assert_includes si.errors, :group_id

    si.group_id = g1
    assert si.valid?
  end

  test 'attempt to modify group on :two' do
    si = sir_items( :two )
    g1 = si.group_id
    g2 = groups( :group_one ).id
    refute_equal g1, g2
    assert si.valid?, si.errors.messages

    si.group_id = g2
    assert si.valid?

    si.group_id = g1
    assert si.valid?
  end

end
