# provides a data structures for tree algorithms
#
# Author: Wilfried Römer

class Node

  attr_accessor :node_info
  attr_accessor :descendants

  def initialize( info = nil )
    @node_info = info
    @descendants = Array.new
  end

  def add_node( n )
    @descendants << n
  end

  def walk( pre_m = nil, post_m = nil )
    pre_m.call unless pre_m.nil?
    @descendants.each { |n| n.walk( pre_m, post_m )}
    post_m.call unless post_m.nil?
  end

end

class Tree

  attr_reader   :node_count
  attr_accessor :root_node

  def initialize( root = nil )
    @node_count = nil
    @root_node = root
  end

  def walk( pre_m = nil, post_m = nil )
    @root_node.walk( pre_m, post_m )
  end

  def count_nodes
    @node_count = 0
    walk( pre_m = Proc.new{ @node_count +=1 })
  end

end

