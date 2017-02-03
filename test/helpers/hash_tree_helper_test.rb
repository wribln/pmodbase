require 'test_helper'
require './lib/assets/hash_tree_helper.rb'
class HashTreeHelperTest < ActionView::TestCase

  test 'create tree' do
    t = HashTree.new( 0 )
    t.add_node( 1, 0 )
    t.add_node( 2, 0 )
    assert_raise ArgumentError do
      t.add_node( 2, 1 )
    end
    assert_raise ArgumentError do 
      t.add_node( 2, 4 )
    end
    assert_raise ArgumentError do
      t.add_node( 3, 4 )
    end

    assert t.has_key? 0
    assert t.has_key? 1
    assert t.has_key? 2
    assert_equal 3, t.size

    # pre-order count

    count = 0
    t.traverse( 0, lambda{ |x| count += 1 })
    assert_equal 3, count

    # post-order count

    count = 0
    t.traverse( 0, nil, lambda{ |x| count += 1 })
    assert_equal 3, count

  end

end