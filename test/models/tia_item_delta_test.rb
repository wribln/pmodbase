require 'test_helper'
class TiaItemDeltaTest < ActiveSupport::TestCase
 
  test 'ensure fixture usefulness' do
    d = tia_item_deltas( :one )
    assert d.comment_changed?
    assert d.valid?
  end

  test 'create test record' do 
    d = TiaItemDelta.new
    assert_nil d.delta_hash
    assert_nil d.tia_item_id
    assert_equal 0, d.delta_count
    refute d.valid?
    assert_includes d.errors, :tia_item_id
    assert_includes d.errors, :base
    d.tia_item_id = tia_items( :tia_item_one ).id
    refute d.valid?
    refute_includes d.errors, :tia_item_id
    assert_includes d.errors, :base
    assert_equal 0, d.delta_count
    d.delta_hash = { 'archived' => false }
    assert_equal 1, d.delta_count
    assert d.valid?
  end

  test 'collect deltas to nil' do
    d = TiaItemDelta.new
    tt = tia_items( :tia_item_one )
    tf = tt.dup

    d.collect_delta_information( tf, tt )
    assert_equal 0, d.delta_count
    refute d.valid?

    refute tt.description.blank?
    tt.description = nil 
    d.collect_delta_information( tf, tt )
    assert_equal 1, d.delta_count
    assert d.description_changed?
    assert_equal tf.description, d.description
    assert d.valid?

    refute tt.comment.blank?
    tt.comment = nil
    d.collect_delta_information( tf, tt )
    assert_equal 2, d.delta_count
    assert d.comment_changed?
    assert_equal tf.comment, d.comment
    assert d.valid?

    refute tt.account_id.nil?
    tt.account_id = nil
    d.collect_delta_information( tf, tt )
    assert_equal 3, d.delta_count
    assert d.account_id_changed?
    assert_equal tf.account_id, d.account_id
    assert d.valid?

    refute tt.prio.nil?
    tt.prio = nil
    d.collect_delta_information( tf, tt )
    assert_equal 4, d.delta_count
    assert d.prio_changed?
    assert_equal tf.prio, d.prio
    assert d.valid?

    refute tt.status.nil?
    tt.status = nil
    d.collect_delta_information( tf, tt )
    assert_equal 5, d.delta_count
    assert d.status_changed?
    assert_equal tf.status, d.status
    assert d.valid?

    refute tt.due_date.nil?
    tt.due_date = nil
    d.collect_delta_information( tf, tt )
    assert_equal 6, d.delta_count
    assert d.due_date_changed?
    assert_equal tf.due_date, d.due_date
    assert d.valid?

    refute tt.archived.nil?
    tt.archived = nil
    d.collect_delta_information( tf, tt )
    assert_equal 7, d.delta_count
    assert d.archived_changed?
    assert_equal tf.archived, d.archived
    assert d.valid?
    assert d.save

  end

  test 'collect deltas to other value' do
    d = TiaItemDelta.new
    tt = tia_items( :tia_item_one )
    tf = tt.dup

    d.collect_delta_information( tf, tt )
    assert_equal 0, d.delta_count
    refute d.valid?

    refute tt.description.blank?
    tt.description = tt.description.reverse
    d.collect_delta_information( tf, tt )
    assert_equal 1, d.delta_count
    assert d.description_changed?
    assert_equal tf.description, d.description
    assert d.valid?

    refute tt.comment.blank?
    tt.comment = tt.comment.reverse
    d.collect_delta_information( tf, tt )
    assert_equal 2, d.delta_count
    assert d.comment_changed?
    assert_equal tf.comment, d.comment
    assert d.valid?

    assert_equal tt.account_id, accounts( :one ).id
    tt.account_id = accounts( :two ).id
    d.collect_delta_information( tf, tt )
    assert_equal 3, d.delta_count
    assert d.account_id_changed?
    assert_equal tf.account_id, d.account_id
    assert d.valid?

    assert_equal 1, tt.prio
    tt.prio = 0
    d.collect_delta_information( tf, tt )
    assert_equal 4, d.delta_count
    assert d.prio_changed?
    assert_equal tf.prio, d.prio
    assert d.valid?

    assert_equal 1, tt.status
    tt.status = 0
    d.collect_delta_information( tf, tt )
    assert_equal 5, d.delta_count
    assert d.status_changed?
    assert_equal tf.status, d.status
    assert d.valid?

    refute tt.due_date.nil?
    tt.due_date += 1
    d.collect_delta_information( tf, tt )
    assert_equal 6, d.delta_count
    assert d.due_date_changed?
    assert_equal tf.due_date, d.due_date
    assert d.valid?

    assert_equal false, tt.archived
    tt.archived = true
    d.collect_delta_information( tf, tt )
    assert_equal 7, d.delta_count
    assert d.archived_changed?
    assert_equal tf.archived, d.archived
    assert d.valid?
    assert d.save

  end
end
