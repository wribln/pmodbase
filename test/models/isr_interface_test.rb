require 'test_helper'
class IsrInterfaceTest < ActiveSupport::TestCase

  test 'fixture 1' do
    isr = isr_interfaces( :one )
    refute_nil isr.if_code
    assert isr.valid?, isr.errors.messages
  end

  test 'labels for levels' do
    isr = IsrInterface.new

    isr.if_level = nil
    assert_nil isr.if_level_label

    isr.if_level = 0
    assert_equal isr.if_level_label, IsrInterface::ISR_IF_LEVEL_LABELS[ 0 ]

    isr.if_level = 4 # max + 1
    assert_nil isr.if_level_label
  end

  test 'labels for status' do
    isr = IsrInterface.new

    isr.if_status = nil
    assert_nil isr.if_status_label

    isr.if_status = 0
    assert_equal isr.if_status_label, IsrInterface::ISR_IF_STATUS_LABELS[ 0 ]

    isr.if_status = 6 # max + 1
    assert_nil isr.if_status_label
  end

  test 'code format' do
    isr = IsrInterface.new

    assert_nil isr.if_code

    isr.id = 1
    assert_equal 'IF-1--', isr.if_code

    isr.l_group_id = groups( :group_one ).id
    assert_equal 'IF-1-ONE-', isr.if_code

    isr.p_group_id = groups( :group_two ).id
    assert_equal 'IF-1-ONE-TWO', isr.if_code
  end

  test 'try all scopes' do
    assert_equal 1, IsrInterface.ff_id( isr_interfaces( :one ).id ).count
    assert_equal 1, IsrInterface.ff_txt( 'Test Interface').count
    assert_equal 1, IsrInterface.ff_txt( 'description' ).count
    assert_equal 0, IsrInterface.ff_txt( 'nada' ).count
    assert_equal 1, IsrInterface.ff_grp( groups( :group_one ).id ).count
    assert_equal 1, IsrInterface.ff_grp( groups( :group_two ).id ).count
    assert_equal 0, IsrInterface.ff_grp( 0 ).count
    assert_equal 1, IsrInterface.ff_lvl( 0 ).count
    assert_equal 0, IsrInterface.ff_lvl( 1 ).count
    assert_equal 1, IsrInterface.ff_sts( 0 ).count
    assert_equal 0, IsrInterface.ff_sts( 1 ).count
    assert_equal 1, IsrInterface.ff_wfs( 0 ).count
    assert_equal 0, IsrInterface.ff_wfs( 1 ).count
  end

end
