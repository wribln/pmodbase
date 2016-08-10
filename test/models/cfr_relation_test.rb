require 'test_helper'
class CfrRelationTest < ActiveSupport::TestCase

  test 'fixture 1' do
    r = cfr_relations( :one )
    assert_equal r.src_record, cfr_records( :one )
    assert_equal r.dst_record, cfr_records( :two )
    assert_equal r.cfr_relationship_id, cfr_relationships( :one_one ).id
    assert r.valid?, r.errors.messages
  end

  test 'fixture 2' do
    r = cfr_relations( :two )
    assert_equal r.src_record, cfr_records( :two )
    assert_equal r.dst_record, cfr_records( :one )
    assert_equal r.cfr_relationship_id, cfr_relationships( :two_one ).id
    assert r.valid?
  end

  test 'defaults' do 
    r = CfrRelation.new

    refute r.valid?
    assert_includes r.errors, :src_record
    assert_includes r.errors, :dst_record
    refute_includes r.errors, :base
    assert_includes r.errors, :cfr_relationship

    r.src_record = cfr_records( :one )
    refute r.valid?
    refute_includes r.errors, :src_record
    assert_includes r.errors, :dst_record
    refute_includes r.errors, :base
    assert_includes r.errors, :cfr_relationship

    r.dst_record = cfr_records( :one )
    refute r.valid?
    refute_includes r.errors, :src_record
    refute_includes r.errors, :dst_record
    assert_includes r.errors, :base
    assert_includes r.errors, :cfr_relationship

    r.cfr_relationship = cfr_relationships( :one_two )
    refute r.valid?
    refute_includes r.errors, :src_record
    refute_includes r.errors, :dst_record
    assert_includes r.errors, :base
    refute_includes r.errors, :cfr_relationship

    r.dst_record = cfr_records( :two )
    refute r.valid?
    refute_includes r.errors, :src_record
    refute_includes r.errors, :dst_record
    assert_includes r.errors, :base
    refute_includes r.errors, :cfr_relationship

    r.cfr_relationship = cfr_relationships( :two_one )
    refute r.valid?
    refute_includes r.errors, :src_record
    refute_includes r.errors, :dst_record
    assert_includes r.errors, :base
    refute_includes r.errors, :cfr_relationship

    r.create_src_record( title: 'test' )
    assert r.valid?
  end

  test 'get label' do
    r = cfr_relations( :one )
    assert_equal 'Relationship 1 Leading', r.get_label( r.src_record_id )
    assert_equal 'Relationship 1 Reverse', r.get_label( r.dst_record_id )
  end

end
