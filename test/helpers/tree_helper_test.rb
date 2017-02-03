require 'test_helper'
require './lib/assets/tree_helper.rb'
class TreeHelperTest < ActionView::TestCase

  test 'tree basics' do  
    t = Tree.new
    assert_nil t.node_count
    assert_nil t.root_node
  end

  test 'node basics' do
    n = Node.new
    assert_nil n.node_info
    assert n.descendants.empty?
  end

  test 'create tree' do
    t = Tree.new
    a1 = Node.new( 'A1' )
    t.root_node = a1
    t.count_nodes
    assert_equal 1, t.node_count

    a2 = Node.new( 'A2' )
    a1.add_node( a2 )
    t.count_nodes
    assert_equal 2, t.node_count
  end

  test 'try payload with level information' do
    PL = Struct.new( :level )
    a1 = Node.new( PL.new( 0 ))
    t = Tree.new( a1 )
    t.count_nodes
    assert_equal 1, t.node_count
  end

end