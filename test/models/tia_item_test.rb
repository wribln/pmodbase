require 'test_helper'
class TiaItemTest < ActiveSupport::TestCase

  test 'fixture usefulness' do
    tia = tia_items( :tia_item_one )
    assert_not_nil tia.tia_list_id
    assert_not_nil tia.account_id
    assert_equal tia.seqno, 1
    assert tia.description.length <= MAX_LENGTH_OF_DESCRIPTION
    assert tia.comment.length <= MAX_LENGTH_OF_DESCRIPTION unless tia.comment.nil?
    assert tia.prio >= 1 && tia.prio <= 3
    assert ( tia.status >= 0 )&&( tia.status <= ( TiaItem::TIA_ITEM_STATUS_LABELS.size - 1 ))
  end

  test 'ensure status dimensions' do
    assert_equal 4, TiaItem::TIA_ITEM_STATUS_LABELS.size
    assert_equal 'open', TiaItem::TIA_ITEM_STATUS_LABELS[ 0 ]
    assert_equal 'waiting', TiaItem::TIA_ITEM_STATUS_LABELS[ 1 ]
    assert_equal 'obsolete', TiaItem::TIA_ITEM_STATUS_LABELS[ 2 ]
    assert_equal 'closed', TiaItem::TIA_ITEM_STATUS_LABELS[ 3 ]
  end

  test 'status labels' do
    tia = TiaItem.new
    tia.status = 0
    assert_equal text_with_id( 'open',      0 ), tia.status_label_with_id
    assert_equal 'open', tia.status_label
    assert_equal tia.status_label, TiaItem.status_label( tia.status )
    assert tia.status_open?
    tia.status = 1
    assert_equal text_with_id( 'waiting',   1 ), tia.status_label_with_id
    assert_equal 'waiting', tia.status_label
    assert_equal tia.status_label, TiaItem.status_label( tia.status )
    assert tia.status_open?
    tia.status = 2
    assert_equal text_with_id( 'obsolete',  2 ), tia.status_label_with_id
    assert_equal 'obsolete', tia.status_label
    assert_equal tia.status_label, TiaItem.status_label( tia.status )
    assert_not tia.status_open?
    tia.status = 3
    assert_equal text_with_id( 'closed',    3 ), tia.status_label_with_id
    assert_equal 'closed', tia.status_label
    assert_equal tia.status_label, TiaItem.status_label( tia.status )
    assert_not tia.status_open?
  end

  test 'ensure prio dimensions' do
    assert_equal 3, TiaItem::TIA_ITEM_PRIO_LABELS.size
    assert_equal 1, TiaItem::TIA_ITEM_PRIO_LABELS[ 0 ]
    assert_equal 2, TiaItem::TIA_ITEM_PRIO_LABELS[ 1 ]
    assert_equal 3, TiaItem::TIA_ITEM_PRIO_LABELS[ 2 ]
  end

  test 'prio labels' do
    tia = TiaItem.new
    tia.prio = 0
    assert_equal 1, tia.prio_label
    assert_equal tia.prio_label, TiaItem.prio_label( tia.prio )
    tia.prio = 1
    assert_equal 2, tia.prio_label
    assert_equal tia.prio_label, TiaItem.prio_label( tia.prio )
    tia.prio = 2
    assert_equal 3, tia.prio_label
    assert_equal tia.prio_label, TiaItem.prio_label( tia.prio )
  end

  test 'required attributes' do
    tx = tia_items( :tia_item_one )
    tn = TiaItem.new
    assert tx.valid?
    assert_not tn.valid?

    assert_includes tn.errors, :tia_list_id
    tn.tia_list_id = tx.tia_list_id
    assert_not tn.valid?
    assert_not_includes tn.errors, :tia_list_id

    assert_includes tn.errors, :description
    tn.description = 'something'
    assert_not tn.valid?
    assert_not_includes tn.errors, :description

    assert_includes tn.errors, :seqno
    tn.seqno = tx.seqno + 1
    assert tn.valid?
  end

  test 'seqno must be unique within list' do
    tx = tia_items( :tia_item_one )
    tn = tx
    tn.id = nil
    assert_not tn.valid?
    tn.seqno += 1
    assert tn.valid?
  end

  test 'account if given must exist' do
    tx = tia_items( :tia_item_one )
    refute_nil tx.account_id
    assert tx.valid?
    Account.find( tx.account_id ).destroy
    tx.reload # to avoid using the data in the cache
    refute tx.valid?
    assert_includes tx.errors, :account_id
  end

  test 'tia list must exist' do
    tx = tia_items( :tia_item_one )
    refute_nil tx.tia_list_id
    assert tx.valid?
    TiaList.find( tx.tia_list_id ).destroy
    assert_raises( ActiveRecord::RecordNotFound ){ tx.reload }
    refute tx.valid?
    assert_includes tx.errors, :tia_list_id
  end

  test 'do not archive unless item is closed' do
    tx = tia_items( :tia_item_one )
    tx.archived = true

    tx.status = 0
    assert tx.status_open?
    assert tx.invalid?
    assert_includes tx.errors, :archived

    tx.status = 1
    assert tx.status_open?
    assert tx.invalid?
    assert_includes tx.errors, :archived

    tx.status = 2
    refute tx.status_open?
    assert tx.valid?

    tx.status = 3
    refute tx.status_open?
    assert tx.valid?
  end

end
