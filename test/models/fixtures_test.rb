# this is a simple test which can be used to verify
# that fixtures are correctly loaded

require 'test_helper'

class FixturesTest < ActiveSupport::TestCase

  test 'fixtures - responsibility one exists' do
    r = responsibilities( :one )
    assert true
  end

  test 'fixtures check group_id for all features' do
    a = accounts( :account_one ).id
    Permission4Group.order( :feature_id ).each do |p|
      assert_equal 0, p.group_id, "group_id not zero for feature #{ p.feature_id }" if p.account_id == a
    end
  end

end