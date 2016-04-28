require 'test_helper'
require './lib/assets/app_helper.rb'
class AppHelperTest < ActionView::TestCase

  test 'fix string' do
    assert '123', fix_string( '123' )
    assert '1234567890', AppHelper.fix_string( '1234567890' )
    assert '1234567890', AppHelper.fix_string( '1234567890', 10, 0 )
    assert '12345678...', AppHelper.fix_string( '12345678901', 10, 0 )
    assert '12345...901', AppHelper.fix_string( '12345678901', 10, 3 )
  end

end
