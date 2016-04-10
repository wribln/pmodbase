require 'test_helper'
class OrlTypeTest < ActiveSupport::TestCase

  test 'fixture' do
    ot = orl_types( :one )
    assert ot.valid?, ot.errors.messages
    refute_nil ot.o_group_id
    refute_nil ot.r_group_id
    refute_nil ot.label
  end

  test 'defaults' do
    ot = OrlType.new
    refute ot.valid?
    assert_includes ot.errors, :o_group_id
    assert_includes ot.errors, :r_group_id
    assert_includes ot.errors, :label

    ot.o_group_id = groups( :group_one ).id
    ot.r_group_id = groups( :group_two ).id
    ot.label = "test 1 2 3"
    assert ot.valid?
  end


end
