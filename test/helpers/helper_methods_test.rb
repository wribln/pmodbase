class TheApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  # override h method which is not available for tests otherwise

  def html_escape( text )
    ERB::Util.html_escape( text )
  end 

  test 'display_boolean' do
    assert 'yes', display_boolean( true )
    assert 'no', display_boolean( false )
    assert '', display_boolean( nil )
  end

  test 'form title with link' do
    @virtual_path = 'dsr_status_records.index'
    assert_match /<h2 class="form-title">.*<a href=.*>test<\/a><\/h2>/,form_title_w_link( 'test', dsr_status_records_path )
  end

  test 'display value' do
    assert_equal '<input class="form-control" value="none" readonly />', display_value( 'none' )
  end

  test 'display lines' do
    assert_equal '<textarea class="form-control" rows="20" cols="40" readonly>test123</textarea>',
      display_lines( 'test123', 20, 40 )
  end

  test 'display lines with breaks' do
    assert_equal 'test<br />123', display_lines_w_br( "test\r\n123" )
  end

  test 'display two items w br' do
    assert_equal '', display_two_items_w_br( nil, nil )
    assert_equal 'item1', display_two_items_w_br( 'item1', nil )
    assert_equal 'item2', display_two_items_w_br( nil, 'item2' )
    assert_equal 'item1<br />item2', display_two_items_w_br( 'item1', 'item2' )
  end

  test 'display nil' do
    assert_equal display_nil, display_value( '' )
  end

end