require 'test_helper'
class DsrStatusRecordsControllerS2Test < ActionController::TestCase
  tests DsrStatusRecordsController

  setup do
    @controller = TestController.new( :index ){ }
  end
  
  test 'merge_stats - end with same key' do
    r = @controller.merge_stats([[ 0,0,0 ],[ 1,1,1 ]],[[ 0,1,1 ],[ 1,1,1 ]],2,1)
    refute_nil r
    assert_equal [0,0,0,0],r[0]
    assert_equal [0,1,0,1],r[1]
    assert_equal [1,1,1,1],r[2]
    s = @controller.sub_totals( r, 1, 2 )
    refute_nil s
    assert_equal [ 0, 0, 1 ], s[ 0 ]
    assert_equal [ 1, 1, 1 ], s[ 1 ]
    g = @controller.grand_total( s, 2 )
    refute_nil g
    assert_equal [ 1, 2 ], g
  end

  test 'try with 2 value columns' do
    r = @controller.merge_stats([[1, 0, 2, 0], [12, 0, 1, 0], [12, 1, 1, 10]], [[1, 0, 2, 0], [12, 0, 0, 0]], 2, 2 )
    refute_nil r 
    assert_equal [  1, 0, 2,  0, 2, 0 ], r[ 0 ]
    assert_equal [ 12, 0, 1,  0, 0, 0 ], r[ 1 ]
    assert_equal [ 12, 1, 1, 10, 0, 0 ], r[ 2 ]
  end

  test 'merge_stats - first ends before second key' do
    r = @controller.merge_stats( [[ 0,0,nil,0 ]], [[ 0,1,nil,1 ],[ 1,1,nil,1 ]], 2, 1)
    refute_nil r
    assert_equal [0,0,0,0],r[0]
    assert_equal [0,1,0,1],r[1]
    assert_equal [1,1,0,1],r[2]
    s = @controller.sub_totals( r, 1, 2 )
    refute_nil s
    assert_equal [ 0, 0, 1 ], s[ 0 ]
    assert_equal [ 1, 0, 1 ], s[ 1 ]
    g = @controller.grand_total( s, 2 )
    refute_nil g
    assert_equal [ 0, 2 ], g
  end

  test 'same as above but with additional values between keys and values' do
    r = @controller.merge_stats( [[ 0,0,nil,'a', 0 ]], [[ 0,1,nil,'b',1 ],[ 1,1,nil,'c',1 ]], 2, 1)
    refute_nil r
    assert_equal [0,0,0,0],r[0]
    assert_equal [0,1,0,1],r[1]
    assert_equal [1,1,0,1],r[2]
    s = @controller.sub_totals( r, 1, 2 )
    refute_nil s
    assert_equal [ 0, 0, 1 ], s[ 0 ]
    assert_equal [ 1, 0, 1 ], s[ 1 ]
    g = @controller.grand_total( s, 2 )
    refute_nil g
    assert_equal [ 0, 2 ], g
  end    

  test 'merge_stats - second ends before first key' do
    r = @controller.merge_stats( [[ 0,0,0 ],[ 1,1,1 ]], [[ 0,1,1 ]], 2, 1 )
    refute_nil r
    assert_equal [0,0,0,0],r[0]
    assert_equal [0,1,0,1],r[1]
    assert_equal [1,1,1,0],r[2]
    s = @controller.sub_totals( r, 1, 2 )
    refute_nil s
    assert_equal [ 0, 0, 1 ], s[ 0 ]
    assert_equal [ 1, 1, 0 ], s[ 1 ]
    g = @controller.grand_total( s, 2 )
    refute_nil g
    assert_equal [ 1, 1 ], g
  end

  test 'merge_stats - first set is empty' do
    r = @controller.merge_stats( [], [[ 0,1,1 ],[ 1,1,1 ]], 2, 1)
    refute_nil r
    assert_equal [0,1,0,1],r[0]
    assert_equal [1,1,0,1],r[1]
    s = @controller.sub_totals( r, 1, 2 )
    refute_nil s
    assert_equal [ 0, 0, 1 ], s[ 0 ]
    assert_equal [ 1, 0, 1 ], s[ 1 ]
    g = @controller.grand_total( s, 2 )
    refute_nil g
    assert_equal [ 0, 2 ], g
  end

  test 'merge_stats - first set is nil' do
    r = @controller.merge_stats( nil, [[ 0,1,1 ],[ 1,1,1 ]], 2, 1)
    refute_nil r
    assert_equal [0,1,0,1],r[0]
    assert_equal [1,1,0,1],r[1]
    s = @controller.sub_totals( r, 1, 2 )
    refute_nil s
    assert_equal [ 0, 0, 1 ], s[ 0 ]
    assert_equal [ 1, 0, 1 ], s[ 1 ]
    g = @controller.grand_total( s, 2 )
    refute_nil g
    assert_equal [ 0, 2 ], g
  end

  test 'merge_stats - bad key values to compare raises exception' do
    assert_raise RuntimeError do
      r = @controller.merge_stats( [[1, 'ADMIN', 0, 2]], [[1, 0, 2]], 2, 1 )
    end
  end

  test 'overalls' do
    r = @controller.over_alls( [[0,0,1,0],[0,1,0,2],[1,1,0,3]], 1, 2 )
    refute_nil r
    assert_equal r[ 0 ], [ 1, 0 ]
    assert_equal r[ 1 ], [ 0, 5 ]
  end

end

class TestController < ApplicationController
  include StatsResultHelper

  def initialize( method_name, &method_body )
    self.class.send( :define_method, method_name, method_body )
  end

end