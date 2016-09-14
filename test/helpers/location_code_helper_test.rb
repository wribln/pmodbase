class LocationCodeHelperTest < ActionView::TestCase
  include LocationCodeHelper

  test 'db_formatted_km' do
    assert_equal '0+000.000', db_formatted_km( 0 )
    assert_equal '0-001.000', db_formatted_km( -1 )
    assert_equal '0-001.000', db_formatted_km( -1 )
    assert_equal '0-011.000', db_formatted_km( -11 )
    assert_equal '0-111.000', db_formatted_km( -111 )
    assert_equal '1-111.000', db_formatted_km( -1111 )
    assert_equal '11-111.000', db_formatted_km( -11111 )
    assert_equal '111-111.000', db_formatted_km( -111111 )
    assert_equal '1111-111.000', db_formatted_km( -1111111)
    assert_equal '0+001.000', db_formatted_km( 1 )
    assert_equal '0+011.000', db_formatted_km( 11 )
    assert_equal '0+111.000', db_formatted_km( 111 )
    assert_equal '1+111.000', db_formatted_km( 1111 )
    assert_equal '11+111.000', db_formatted_km( 11111 )
    assert_equal '111+111.000', db_formatted_km( 111111 )
    assert_equal '1111+111.000', db_formatted_km( 1111111)

    assert_equal '1111+111.000', db_formatted_km( 1111111.00049)
    assert_equal '1111+111.001', db_formatted_km( 1111111.00050)
    assert_equal '1111+111.001', db_formatted_km( 1111111.00051)

    assert_equal '0+000', db_formatted_km( 0.001, false )
    assert_equal '0+000', db_formatted_km( 0.011, false )
    assert_equal '0+000', db_formatted_km( 0.111, false )
    assert_equal '0+000', db_formatted_km( 0.499, false )
    assert_equal '0+001', db_formatted_km( 0.500, false )
    assert_equal '0+001', db_formatted_km( 0.501, false )
  end

  test 'db_formatted_km_len' do
    assert_equal '0.000', db_formatted_km_len( 0 )
    assert_equal '-1.000', db_formatted_km_len( -1 )
    assert_equal '-1.000', db_formatted_km_len( -1 )
    assert_equal '-11.000', db_formatted_km_len( -11 )
    assert_equal '-111.000', db_formatted_km_len( -111 )
    assert_equal '-1 111.000', db_formatted_km_len( -1111 )
    assert_equal '-11 111.000', db_formatted_km_len( -11111 )
    assert_equal '-111 111.000', db_formatted_km_len( -111111 )
    assert_equal '-1 111 111.000', db_formatted_km_len( -1111111)
    assert_equal '1.000', db_formatted_km_len( 1 )
    assert_equal '11.000', db_formatted_km_len( 11 )
    assert_equal '111.000', db_formatted_km_len( 111 )
    assert_equal '1 111.000', db_formatted_km_len( 1111 )
    assert_equal '11 111.000', db_formatted_km_len( 11111 )
    assert_equal '111 111.000', db_formatted_km_len( 111111 )
    assert_equal '1 111 111.000', db_formatted_km_len( 1111111)

    assert_equal '1 111 111.000', db_formatted_km_len( 1111111.00049)
    assert_equal '1 111 111.001', db_formatted_km_len( 1111111.00050)
    assert_equal '1 111 111.001', db_formatted_km_len( 1111111.00051)

    assert_equal '0', db_formatted_km_len( 0.001, false )
    assert_equal '0', db_formatted_km_len( 0.011, false )
    assert_equal '0', db_formatted_km_len( 0.111, false )
    assert_equal '0', db_formatted_km_len( 0.499, false )
    assert_equal '1', db_formatted_km_len( 0.500, false )
    assert_equal '1', db_formatted_km_len( 0.501, false )

    assert_equal '1 111 111', db_formatted_km_len( 1111111.49, false )
    assert_equal '1 111 112', db_formatted_km_len( 1111111.50, false )
    assert_equal '1 111 112', db_formatted_km_len( 1111111.51, false )
  end

end
