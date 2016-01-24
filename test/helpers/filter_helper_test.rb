require 'test_helper'
class AppHelperTest < ActionView::TestCase

  test "clean_up" do
    ap = ActionController::Parameters.new( k1: "", k2: "0", k3: nil, k4: [] )
    an = ap.clean_up
    assert_equal ({ 'k2' => '0' }), an
  end

  test "clean_up 1" do
    ap = ActionController::Parameters.new( k1: "1,2,3" )
    an = ap.clean_up
    assert_equal ({ 'k1' => '1,2,3' }), an
  end     

  test "map_values" do
    assert_equal ({ test1: '1', test2: '2' }),map_values( '1,2', :test1, :test2 )
    assert_equal ({ test2: '2' }), map_values( ',2,3', :test1, :test2 )
    assert_equal ({ test1: '1' }), map_values( '1', :test1, :test2 )
    assert_equal ({ test2: '2' }), map_values( ',2', :test1, :test2 )
    assert_equal ({ test1: '1', test3: '3' }), map_values( '1,,3', :test1, :test2, :test3 )
  end

end
