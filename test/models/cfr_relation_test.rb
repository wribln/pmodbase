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
    assert_includes r.errors, :src_record_id
    assert_includes r.errors, :dst_record_id
    refute_includes r.errors, :base
    assert_includes r.errors, :cfr_relationship_id

    r.src_record = cfr_records( :one )
    refute r.valid?
    refute_includes r.errors, :src_record_id
    assert_includes r.errors, :dst_record_id
    refute_includes r.errors, :base
    assert_includes r.errors, :cfr_relationship_id

    r.dst_record = cfr_records( :one )
    refute r.valid?
    refute_includes r.errors, :src_record_id
    refute_includes r.errors, :dst_record_id
    assert_includes r.errors, :base
    assert_includes r.errors, :cfr_relationship_id

    r.cfr_relationship = cfr_relationships( :one_two )
    refute r.valid?
    refute_includes r.errors, :src_record_id
    refute_includes r.errors, :dst_record_id
    assert_includes r.errors, :base
    refute_includes r.errors, :cfr_relationship_id

    r.dst_record = cfr_records( :two )
    refute r.valid?
    refute_includes r.errors, :src_record_id
    refute_includes r.errors, :dst_record_id
    assert_includes r.errors, :base
    refute_includes r.errors, :cfr_relationship_id

    r.cfr_relationship = cfr_relationships( :two_one )
    refute r.valid?
    refute_includes r.errors, :src_record_id
    refute_includes r.errors, :dst_record_id
    assert_includes r.errors, :base
    refute_includes r.errors, :cfr_relationship_id

    r.src_record = CfrRecord.new( title: 'test' )
    assert r.valid?
  end

  test 'get label' do
    r = cfr_relations( :one )
    assert_equal 'Relationship 1 Leading', r.get_label( r.src_record )
    assert_equal 'Relationship 1 Reverse', r.get_label( r.dst_record )
  end

  test 'src and dst must exist' do
    r = cfr_relations( :one )
    r.src_record_id = nil
    refute r.valid?
    assert_includes r.errors, :src_record_id

    r.src_record_id = accounts( :wop ).id
    refute r.valid?
    assert_includes r.errors, :src_record_id

    r.dst_record_id, r.src_record_id = r.src_record_id, r.dst_record_id
    refute r.valid?
    assert_includes r.errors, :dst_record_id

    r.dst_record_id = nil
    refute r.valid?
    assert_includes r.errors, :dst_record_id
  end

  test 'cfr_relationship must exist' do
    r = cfr_relations( :one )
    r.cfr_relationship_id = nil
    refute r.valid?
    assert_includes r.errors, :cfr_relationship_id

    r.cfr_relationship_id = accounts( :wop ).id
    refute r.valid?
    assert_includes r.errors, :cfr_relationship_id
  end

end
