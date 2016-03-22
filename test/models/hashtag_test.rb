require 'test_helper'
class HashtagTest < ActiveSupport::TestCase

  test 'defaults' do
    ht = Hashtag.new
    assert ht.code.nil?
    assert ht.label.nil?
    assert ht.feature_id.nil?
  end

  test 'required fields' do
    ht = Hashtag.new
    refute ht.valid?
    assert_includes ht.errors, :code
    assert_includes ht.errors, :label
    assert_includes ht.errors, :feature_id
    ht = hashtags( :one )
    ht.seqno = nil
    refute ht.valid?
    assert_includes ht.errors, :seqno
  end

  test 'fixture' do
    ht = hashtags( :one )
    assert_equal ht.code,'#ABC'
    assert_equal ht.feature_id, features( :feature_55 ).id
    assert_equal 1, ht.seqno
  end

  test 'hash syntax' do
    ht = hashtags( :one )
    assert ht.valid?

    ht.code = 'ABC'
    refute ht.valid?
    assert_includes ht.errors, :code

    ht.code = '#_ABC'
    refute ht.valid?
    assert_includes ht.errors, :code

    ht.code = '#0ABC'
    refute ht.valid?
    assert_includes ht.errors, :code

    ht.code = '#A_B'
    assert ht.valid?

    ht.code = '#A0B'
    assert ht.valid?
  end
  
end
