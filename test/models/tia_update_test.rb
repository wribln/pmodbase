require 'test_helper'
class TiaUpdateTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    tu = tia_updates( :tia_update_one )
    assert_not_nil tu.tia_item_id
    assert_not_nil tu.account_id
    assert tu.comment.length <= MAX_LENGTH_OF_DESCRIPTION unless tu.description.nil?
    assert tu.description.length <= MAX_LENGTH_OF_DESCRIPTION unless tu.description.nil?
    assert tu.prio >= 1 && tu.prio <= 3
    assert ( tu.status >= 0 )&&( tu.status <= ( TiaItem::TIA_ITEM_STATUS_LABELS.size - 1 ))

    ti = tia_items( :tia_item_one )
    assert ti.prio < 3
    assert ti.status <( TiaItem::TIA_ITEM_STATUS_LABELS.size - 1 )
    assert_equal ti.account_id, accounts( :account_one ).id
  end

  test "required attributes" do
    tx = tia_updates( :tia_update_one )
    tn = TiaUpdate.new
    assert tx.valid?

    assert_not tn.valid?
    assert_not_includes tn.errors, :account_id

    assert_includes tn.errors, :tia_item_id
    tn.tia_item_id = tx.tia_item_id
    assert tn.valid?
  end

  test 'prio labels' do
    tx = TiaUpdate.new
    tx.prio = nil
    assert_nil tx.prio_label
    tx.prio = 0
    assert_equal TiaItem::TIA_ITEM_PRIO_LABELS[ 0 ], tx.prio_label
  end

  test "account if given must exist" do
    tx = tia_updates( :tia_update_one )
    assert_not_nil tx.account_id
    assert tx.valid?
    Account.find( tx.account_id ).destroy
    assert_not tx.valid?
    assert_includes tx.errors, :account_id
  end

  test "tia item must exist" do
    tx = tia_updates( :tia_update_one )
    assert_not_nil tx.tia_item_id
    assert tx.valid?
    TiaItem.find( tx.tia_item_id ).destroy
    assert_not tx.valid?
    assert_includes tx.errors, :tia_item_id
  end

  test "copy modified fields" do
    tt = tia_items( :tia_item_one )
    tf = tt.dup

    tu = TiaUpdate.new
    assert_equal 0, tu.fields_updated
    tu.copy_changes( tf, tt )
    assert_equal 0, tu.fields_updated
    assert_nil tu.tia_item_id
    assert_not tu.valid?

    tt.description += '+'
    tu.copy_changes( tf, tt )
    assert_equal 1, tu.fields_updated
    assert_not_nil tu.tia_item_id
    assert_equal tu.tia_item_id, tt.id
    assert tu.valid?

    tt.comment += '+'
    tu.copy_changes( tf, tt )
    assert_equal 2, tu.fields_updated
    assert tu.valid?

    tt.prio += 1
    tu.copy_changes( tf, tt )
    assert_equal 3, tu.fields_updated
    assert tu.valid?

    tt.status += 1
    tu.copy_changes( tf, tt )
    assert_equal 4, tu.fields_updated
    assert tu.valid?

    tt.account_id = accounts( :account_two ).id
    tu.copy_changes( tf, tt )
    assert_equal 5, tu.fields_updated
    assert tu.valid?

    tt.due_date += 1
    tu.copy_changes( tf, tt )
    assert_equal 6, tu.fields_updated
    assert tu.valid?

  end

end
 