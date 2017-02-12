require 'test_helper'
class SirItemTest < ActiveSupport::TestCase

  test 'fixture 1' do 
    si = sir_items( :one )
    refute_nil si.sir_log_id
    refute_nil si.group_id
    assert_equal 1, si.seqno
    refute_nil si.reference
    refute_nil si.cfr_record_id
    assert_equal 0, si.status
    assert_equal 1, si.category
    refute_nil si.phase_code_id
    refute si.archived
    refute_nil si.description
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

    se = si.sir_entries.build( rec_type: 0, group_id: groups( :group_one ).id, description: 'test 1' )
    assert_equal 0, si.validate_entries
    refute se.valid?
    assert_includes se.errors, :base # forward to itself

    se.rec_type = 2
    refute se.valid?
    assert_includes se.errors, :base # respond to item owner


    se.group_id = groups( :group_two ).id
    refute se.valid?
    assert_includes se.errors, :base # respond to other group

    se.rec_type = 1
    refute se.valid?
    assert_includes se.errors, :base # comment to other group

    se.rec_type = 0
    assert se.save, se.errors.messages
    si.reload
    assert_equal 0, si.validate_entries

    # next entry

    se = si.sir_entries.build( rec_type: 0, group_id: groups( :group_one ).id, description: 'test 2')
    assert_equal 0, si.validate_entries
    refute se.valid?
    assert_includes se.errors, :base # forward to item owner

    se.group = groups( :group_two )
    refute se.valid?
    assert_includes se.errors, :base # forward to previous entry

    gp = Group.new( code: 'XXX', group_category_id: group_categories( :group_category_one ).id, label: 'XXX-Group' )
    assert gp.save, gp.errors.messages

    se.group_id = gp.id
    assert se.valid?

    se.rec_type = 1
    refute se.valid?
    assert_includes se.errors, :base # comment to other group

    se.group_id = groups( :group_two ).id
    assert se.valid?

    se.rec_type = 2
    refute se.valid?
    assert_includes se.errors, :base # respond to own group

    se.group_id = gp.id
    refute se.valid?
    assert_includes se.errors, :base # respond to other group

    se.group_id = groups( :group_one ).id
    assert se.valid?

  end



end
