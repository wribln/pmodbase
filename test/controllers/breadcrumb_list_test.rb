require 'test_helper'
class BreadcrumbListTest < ActionController::TestCase

  def validate_breadcrumb_list
    # there must be a list to validate
    refute_nil @controller.breadcrumbs_to_here
    # first entry must relate to base page
    assert_equal 'base', @controller.breadcrumbs_to_here[ 0 ][ 0 ]
    assert_equal '/base/index', @controller.breadcrumbs_to_here[ 0 ][ 1 ]
    # all other entries
    @controller.breadcrumbs_to_here[1..-1].each do |bc|
      refute_nil bc, 'breadcrumb tupel must not be nil'
      if bc[ 0 ].nil? then
        assert_same bc, @controller.breadcrumbs_to_here.last, 'first element of breadcrumb tupel may only be nil when it is the last breadcrumb'
        assert bc[ 1 ].kind_of?( String ) || bc[ 1 ].kind_of?( Symbol ), 'second element of breadcrumb tupel must be a string or symbol (action)'
      else
        assert bc[ 0 ].kind_of?( String ) || bc[ 0 ].kind_of?( Symbol ), 'first element of breadcrumb tupel must be a string or symbol (controller)'
        assert ( bc[ 1 ].nil? || bc[ 1 ].kind_of?( String )), 'if second element of breadcrumb tupel is not nil, it must be a string (path)'
      end
    end
  end

  test 'all methods' do
    @controller = BreadcrumbTestsController.new( :index ){ }
    session[ :keep_base_open ]
    with_routing do |set|
      set.draw do
        resources :breadcrumb_tests
        get  'base/index', as: 'base', format: false
      end

    begin # 'breadcrumb on index' do
      get :index
      validate_breadcrumb_list
      assert_equal 'breadcrumb_tests', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
      assert_equal '/breadcrumb_tests', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
      assert_equal 'index', @controller.breadcrumbs_to_here.last[ 1 ]
    end

    begin # 'set_final_breadcrumb' do
      @controller.set_final_breadcrumb( :show )
      validate_breadcrumb_list
      assert_equal 'breadcrumb_tests', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
      assert_equal '/breadcrumb_tests', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
      assert_equal :show, @controller.breadcrumbs_to_here.last[ 1 ]
    end

    begin # 'parent_breadcrumb' do
      @controller.parent_breadcrumb( 'test', '/testpath' )
      validate_breadcrumb_list
      assert_equal 'test', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
      assert_equal '/testpath', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
      assert_equal 'breadcrumb_tests', @controller.breadcrumbs_to_here[ 2 ][ 0 ]
      assert_equal '/breadcrumb_tests', @controller.breadcrumbs_to_here[ 2 ][ 1 ]
      assert_equal :show, @controller.breadcrumbs_to_here.last[ 1 ]
    end

    begin # 'set_breadcrumb_title' do
      @controller.set_breadcrumb_title( 'xxxx' )
      validate_breadcrumb_list
      assert_equal 'test', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
      assert_equal '/testpath', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
      assert_equal 'xxxx', @controller.breadcrumbs_to_here[ 2 ][ 0 ]
      assert_equal '/breadcrumb_tests', @controller.breadcrumbs_to_here[ 2 ][ 1 ]
      assert_equal :show, @controller.breadcrumbs_to_here.last[ 1 ]
    end

    begin # 'set_breadcrumb_path' do
      @controller.set_breadcrumb_path( '/xxxx_path' )
      validate_breadcrumb_list
      assert_equal 'test', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
      assert_equal '/testpath', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
      assert_equal 'xxxx', @controller.breadcrumbs_to_here[ 2 ][ 0 ]
      assert_equal '/xxxx_path', @controller.breadcrumbs_to_here[ 2 ][ 1 ]
      assert_equal :show, @controller.breadcrumbs_to_here.last[ 1 ]
    end

    begin # 'set_final_breadcrumb with nil' do
      @controller.set_final_breadcrumb( nil )
      validate_breadcrumb_list
      assert_equal 'test', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
      assert_equal '/testpath', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
      assert_equal 'xxxx', @controller.breadcrumbs_to_here[ 2 ][ 0 ]
      assert_nil @controller.breadcrumbs_to_here[ 2 ][ 1 ]
    end

    end
  end

end

class BreadcrumbTestsController < ApplicationController
	include BreadcrumbList

  def initialize( method_name, &method_body )
    self.class.send( :define_method, method_name, method_body )
  end

end