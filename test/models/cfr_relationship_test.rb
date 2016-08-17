require 'test_helper'
class CfrRelationshipTest < ActiveSupport::TestCase

  test 'check fixtures one' do
    t1 = cfr_relationships( :one_one )
    assert t1.valid?, t1.errors.messages
    t2 = t1.reverse_rs
    assert t2.valid?
  end

  test 'check fixtures two' do
    t1 = cfr_relationships( :two_one )
    assert t1.valid?, t1.errors.messages
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
    t1 = cfr_relationships( :one_one )
    t2 = cfr_relationships( :one_two )

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

  test 'get_option_list' do
    ol = CfrRelationship.get_option_list
    assert ol.key? 'sequential'
    assert ol.key? 'hierarchical'
    refute ol.key? 'other'
    assert_equal 2, ol[ 'sequential' ].count
    assert_equal 2, ol[ 'hierarchical' ].count
    assert ol[ 'sequential'   ][ 0 ].eql? [ cfr_relationships( :one_one ).label, cfr_relationships( :one_one ).id ]
    assert ol[ 'sequential'   ][ 1 ].eql? [ cfr_relationships( :one_two ).label, cfr_relationships( :one_two ).id ]
    assert ol[ 'hierarchical' ][ 0 ].eql? [ cfr_relationships( :two_one ).label, cfr_relationships( :two_one ).id ]
    assert ol[ 'hierarchical' ][ 1 ].eql? [ cfr_relationships( :two_two ).label, cfr_relationships( :two_two ).id ]
  end

end
