require 'test_helper'
class BreadcrumbListTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    session[ :keep_base_open ] = false
  end    

  test 'index' do
    get abbreviations_path
    validate_breadcrumb_list
    assert_equal 'abbreviations', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
    assert_equal '/aaa', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
    assert_equal 'index', @controller.breadcrumbs_to_here.last[ 1 ]
  end

  test 'show' do
    get abbreviation_path( id: abbreviations( :sag ))
    validate_breadcrumb_list
    assert_equal 'abbreviations', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
    assert_equal '/aaa', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
    assert_equal 'show', @controller.breadcrumbs_to_here.last[ 1 ]
  end

  test 'parent_breadcrumb' do
    get abbreviation_path( id: abbreviations( :sag ))
    @controller.parent_breadcrumb( 'test', '/testpath' )
    validate_breadcrumb_list
    assert_equal 'test', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
    assert_equal '/testpath', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
    assert_equal 'abbreviations', @controller.breadcrumbs_to_here[ 2 ][ 0 ]
    assert_equal '/aaa', @controller.breadcrumbs_to_here[ 2 ][ 1 ]
    assert_equal 'show', @controller.breadcrumbs_to_here.last[ 1 ]

    @controller.set_breadcrumb_title( 'xxxx' )
    validate_breadcrumb_list
    assert_equal 'test', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
    assert_equal '/testpath', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
    assert_equal 'xxxx', @controller.breadcrumbs_to_here[ 2 ][ 0 ]
    assert_equal '/aaa', @controller.breadcrumbs_to_here[ 2 ][ 1 ]
    assert_equal 'show', @controller.breadcrumbs_to_here.last[ 1 ]

    @controller.set_breadcrumb_path( '/xxxx_path' )
    validate_breadcrumb_list
    assert_equal 'test', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
    assert_equal '/testpath', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
    assert_equal 'xxxx', @controller.breadcrumbs_to_here[ 2 ][ 0 ]
    assert_equal '/xxxx_path', @controller.breadcrumbs_to_here[ 2 ][ 1 ]
    assert_equal 'show', @controller.breadcrumbs_to_here.last[ 1 ]

    @controller.set_final_breadcrumb( nil )
    validate_breadcrumb_list
    assert_equal 'test', @controller.breadcrumbs_to_here[ 1 ][ 0 ]
    assert_equal '/testpath', @controller.breadcrumbs_to_here[ 1 ][ 1 ]
    assert_equal 'xxxx', @controller.breadcrumbs_to_here[ 2 ][ 0 ]
    assert_nil @controller.breadcrumbs_to_here[ 2 ][ 1 ]
  end

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

end
