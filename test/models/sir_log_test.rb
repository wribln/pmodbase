require 'test_helper'
class SirLogTest < ActiveSupport::TestCase

  test 'fixture' do
    sl = sir_logs( :one )
    refute_nil sl.label
    refute_nil sl.desc
  end

  test 'defaults' do
    sl = SirLog.new
    assert_nil sl.label
    assert_nil sl.desc

    refute sl.valid?
    assert_includes sl.errors, :label
    sl.label = 'some text'
    assert sl.valid?
  end

end
