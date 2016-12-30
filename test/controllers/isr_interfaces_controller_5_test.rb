require 'test_helper'
class IsrInterfacesController5Test < ActionController::TestCase
  tests IsrInterfacesController

  # test withdrawal of IF and related interfaces

  setup do
    @isr_interface = isr_interfaces( :one ) 
    @isr_agreement = isr_agreements( :one )
    @account = accounts( :one )
    pg = @account.permission4_groups.where( feature_id: FEATURE_ID_ISR_INTERFACES )
    pg[ 0 ].to_read = 2
    pg[ 0 ].to_update = 2
    pg[ 0 ].to_create = 2
    assert pg[ 0 ].save, pg[ 0 ].errors.messages
    session[ :current_user_id ] = @account.id
  end

  test 'withdrawal feature' do

    # create interface

    assert_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: 'new interface' }
    end
    isf = assigns( :isr_interface )
    refute_nil isf
    assert_redirected_to isr_interface_details_path( isf )
    assert_equal 0, isf.if_status

    # create associated agreements - on per possible status

    assert_difference( 'IsrAgreement.count', 1 )do
      post :create_ia, id: isf, isr_interface: { note: '' },
        isr_agreement: { ia_type: 0,
        l_group_id: @isr_interface.l_group_id,
        l_owner_id: @account.id,
        p_group_id: @isr_interface.p_group_id,
        p_owner_id: @account.id,
        def_text: 'test definition' }
    end
    isf = assigns( :isr_interface )
    refute_nil isf
    isa0 = assigns( :isr_agreement )
    refute_nil isa0
    assert_redirected_to isr_agreement_details_path( isa0 )
    assert_equal 0, isa0.ia_status
    assert_equal 1, isa0.ia_no

    isa1 = isa0.dup
    isa1.ia_no = 2
    isa1.ia_status = 1
    assert isa1.save, isa1.errors.messages

    isa2 = isa0.dup
    isa2.ia_no = 3
    isa2.ia_status = 2
    assert isa2.save, isa2.errors.messages

    isa3 = isa0.dup
    isa3.ia_no = 4
    isa3.ia_status = 3
    assert isa3.save, isa3.errors.messages

    isa4 = isa0.dup
    isa4.ia_no = 5
    isa4.ia_status = 4
    assert isa4.save, isa4.errors.messages

    isa5 = isa0.dup
    isa5.ia_no = 6
    isa5.ia_status = 5
    assert isa5.save, isa5.errors.messages

    isa6= isa0.dup
    isa6.ia_no = 7
    isa6.ia_status = 6
    assert isa6.save, isa6.errors.messages

    isa7 = isa0.dup
    isa7.ia_no = 8
    isa7.ia_status = 7
    assert isa7.save, isa7.errors.messages

    isa8 = isa0.dup
    isa8.ia_no = 9
    isa8.ia_status = 8
    assert isa8.save, isa8.errors.messages

    isa9 = isa0.dup
    isa9.ia_no = 10
    isa9.ia_status = 9
    assert isa9.save, isa9.errors.messages

    assert_equal 10, isf.isr_agreements.count

    # preparation complete - now the action

    assert_no_difference([ 'IsrInterface.count', 'IsrAgreement.count' ]) do
      patch :update, id: isf, commit: I18n.t( 'button_label.wdr' ), isr_interface: { note: 'withdrawal' }
    end
    assert_redirected_to isr_interface_path( isf )
    isf.reload
    assert_equal 4, isf.if_status

    isf.isr_agreements.each do |ia|
      case ia.ia_no
      when 3, 4, 7, 8, 10
        assert_equal ia.ia_no - 1, ia.ia_status
      when 1, 2, 5, 6, 9
        assert_equal 8, ia.ia_status
      else
        fail "invalid agreement no: #{ ia.ia_no }"
      end
    end
  end

end
