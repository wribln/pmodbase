require 'test_helper'
require './lib/core_ext/string.rb'
class StringTest < ActionView::TestCase

  test 'is_n' do
    refute 'a string'.is_n?
    refute ''.is_n?
    assert '0'.is_n?
    refute ' 0'.is_n?
    assert '01'.is_n?
    assert '12345678901'
    refute '+1'.is_n?
  end

end
