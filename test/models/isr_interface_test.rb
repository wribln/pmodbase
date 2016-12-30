require 'test_helper'
class IsrInterfaceTest < ActiveSupport::TestCase

  test 'fixture 1' do
    isr = isr_interfaces( :one )
    refute_nil isr.code
    assert isr.valid?, isr.errors.messages
  end

  test 'defaults' do
    isr = IsrInterface.new
    assert_nil isr.code
    assert_nil isr.l_group_id
    assert_nil isr.p_group_id
    assert_nil isr.title
    assert_nil isr.desc
    assert_equal false, isr.safety_related
    assert_nil isr.cfr_record_id
    assert_equal 0, isr.if_level
    assert_equal 0, isr.if_status
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

    assert_nil isr.code

    isr.id = 1
    assert_equal 'IF-001--', isr.code

    isr.l_group_id = groups( :group_one ).id
    assert_equal 'IF-001-ONE-', isr.code

    isr.p_group_id = groups( :group_two ).id
    assert_equal 'IF-001-ONE-TWO', isr.code
  end

  test 'try all scopes' do
    isr = isr_interfaces( :one )

    as = IsrInterface.ff_id( isr.id )
    assert_equal 1, as.length

    as = IsrInterface.ff_id( 0 )
    assert_equal 0, as.length

    as = IsrInterface.ff_grp( isr.l_group_id )
    assert_equal 1, as.length

    as = IsrInterface.ff_grp( isr.p_group_id )
    assert_equal 1, as.length

    as = IsrInterface.ff_grp( 0 )
    assert_equal 0, as.length

    as = IsrInterface.ff_txt( 'Test' )
    assert_equal 1, as.length

    as = IsrInterface.ff_txt( 'description' )
    assert_equal 1, as.length

    as = IsrInterface.ff_txt( 'nothing' )
    assert_equal 0, as.length

    as = IsrInterface.ff_lvl( 0 )
    assert_equal 1, as.length

    as = IsrInterface.ff_lvl( 1 )
    assert_equal 0, as.length

    as = IsrInterface.ff_sts( 0 )
    assert_equal 1, as.length

    as = IsrInterface.ff_sts( 1 )
    assert_equal 0, as.length

    # association scopes

    as = IsrInterface.includes( :active_agreements ).ff_ats( 0 )
    assert_equal 1, as.length

    as = IsrInterface.includes( :active_agreements ).ff_ats( 1 )
    assert_equal 0, as.length

    as = IsrInterface.includes( :active_agreements ).ff_wfs( 0 )
    assert_equal 1, as.length

    as = IsrInterface.includes( :active_agreements ).ff_wfs( 1 )
    assert_equal 0, as.length

  end

end
