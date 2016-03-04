class LocationCodeHelperTest < ActionView::TestCase
  include LocationCodeHelper

  test 'db_formatted_km' do
    assert_equal '0+000', db_formatted_km( 0 )
    assert_equal '0-001', db_formatted_km( -1 )
    assert_equal '0-001', db_formatted_km( -1 )
    assert_equal '0-011', db_formatted_km( -11 )
    assert_equal '0-111', db_formatted_km( -111 )
    assert_equal '1-111', db_formatted_km( -1111 )
    assert_equal '11-111', db_formatted_km( -11111 )
    assert_equal '111-111', db_formatted_km( -111111 )
    assert_equal '1111-111', db_formatted_km( -1111111)
    assert_equal '0+001', db_formatted_km( 1 )
    assert_equal '0+011', db_formatted_km( 11 )
    assert_equal '0+111', db_formatted_km( 111 )
    assert_equal '1+111', db_formatted_km( 1111 )
    assert_equal '11+111', db_formatted_km( 11111 )
    assert_equal '111+111', db_formatted_km( 111111 )
    assert_equal '1111+111', db_formatted_km( 1111111)
  end

end
