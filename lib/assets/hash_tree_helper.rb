# provides a data structures for tree algorithms - implemented as hash
#
# Author: Wilfried Römer

class HashTree < Hash

  # initialize tree with root key

  def initialize( root )
    super
    self[ root ] = Array.new
  end

  # add a node to the tree: this scheme ensures that the result is always an in-tree
  # without loops; returns value of first parameter

  def add_node( me, my_parent )
    raise ArgumentError.new( 'node already exists' )if self.has_key?( me )
    raise ArgumentError.new( 'parent node does not exist' )unless self.has_key?( my_parent )
    self[ me ] = Array.new
    self[ my_parent ] << me
  end

  # traverse tree recursivly starting at node with key k
  # pre_proc is called for pre-order traversal,
  # post_proc is called for post-order traversal.
  # both procs are called with the current key k

  def traverse( k, pre_proc = nil, post_proc = nil )
    pre_proc.call( k ) unless pre_proc.nil?
    self[ k ].each{ |n| traverse( n, pre_proc, post_proc )}
    post_proc.call( k ) unless post_proc.nil?
  end

end  
