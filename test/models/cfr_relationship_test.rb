require 'test_helper'
class CfrRelationshipTest < ActiveSupport::TestCase

  test 'check fixtures' do
    t1 = cfr_relationships( :one )
    assert t1.valid?
    t2 = t1.reverse_rs
    assert t2.valid?
  end

  test 'defaults' do
    t = CfrRelationship.new
    assert_nil t.label
    refute t.leading
    assert_equal t.rs_group, 2
    assert_nil t.reverse_rs_id
  end

  test 'relationship constraints' do
    t1 = cfr_relationships( :one )
    t2 = cfr_relationships( :two )

    # try with nil

    t1.reverse_rs_id = nil
    assert t1.valid?
    assert t2.valid?

    # try with invalid id

    t1.reverse_rs_id = 0
    refute t1.valid?
    assert_includes t1.errors, :reverse_rs_id
    assert_equal t1.errors[ :reverse_rs_id ], [ I18n.t( 'cfr_relationships.msg.bad_reverse' )]
    assert t2.valid?
    t1.reverse_rs_id = t2.id

    # try with wrong id

    t3 = CfrRelationship.new
    t3.label = 'test'
    t3.reverse_rs_id = t1.id
    refute t3.valid?
    assert_includes t3.errors, :reverse_rs_id
    assert_equal t3.errors[ :reverse_rs_id ], [ I18n.t( 'cfr_relationships.msg.wrong_reverse' )]

    # try with different rs_groups

    t1.rs_group = 1
    refute t1.valid?
    assert_includes t1.errors, :rs_group
    assert_equal t1.errors[ :rs_group ], [ I18n.t( 'cfr_relationships.msg.bad_rs_group' )]

    # try with same leading flag

    t1.rs_group = t2.rs_group
    t1.leading = t2.leading
    refute t1.valid?
    assert_includes t1.errors, :leading
    assert_equal t1.errors[ :leading ], [ I18n.t( 'cfr_relationships.msg.bad_leading' )]

  end

end