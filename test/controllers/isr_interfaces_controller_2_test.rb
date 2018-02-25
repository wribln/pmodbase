require 'test_helper'
class IsrInterfacesController2Test < ActionDispatch::IntegrationTest

  # try steps in workflow 0 - non-standard path: create to withdraw

  setup do
    @isr_interface = isr_interfaces( :one ) 
    @isr_agreement = isr_agreements( :one )
    @account = accounts( :one )
    pg = @account.permission4_groups.where( feature_id: FEATURE_ID_ISR_INTERFACES )
    pg[ 0 ].to_read = 2
    pg[ 0 ].to_update = 2
    pg[ 0 ].to_create = 2
    assert pg[ 0 ].save, pg[ 0 ].errors.messages
    signon_by_user @account
  end

  test 'test workflow 0' do

    # create interface

    assert_difference( 'IsrInterface.count' ) do
      post isr_interfaces_path( params:{ isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: 'new interface' }})
    end
    isf = assigns( :isr_interface )
    refute_nil isf
    assert_redirected_to isr_interface_details_path( isf )
    assert_equal 0, isf.if_status

    # create associated agreement

    assert_difference( 'IsrAgreement.count', 1 )do
      post isr_agreement_path( id: isf, params:{ isr_interface: { note: '' },
        isr_agreement: { ia_type: '0',
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id,
        def_text: 'test definition' }})
    end
    isf = assigns( :isr_interface )
    refute_nil isf
    isa = assigns( :isr_agreement )
    refute_nil isa
    assert_redirected_to isr_agreement_details_path( isa )

    isa.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 0, isa.current_status
    assert_equal 1, isa.current_task

    # next: Task 1 Prepare

    patch isr_agreement_path( id: isa, params:{ isr_interface: { note: '' }, isr_agreement: { def_text: 'next task: prepare', l_owner_id: @account.id }, next_status_task: 1 })
    assert_redirected_to isr_agreement_details_path( isa )

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 1, isa.current_status
    assert_equal 2, isa.current_task

    # next: Task 5 Modify

    patch isr_agreement_path( id: isa, params:{ isr_interface: { note: '' }, isr_agreement: { def_text: 'update definition' }, next_status_task: 3 })

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 4, isa.current_status
    assert_equal 5, isa.current_task

    # next: back to Prepare

    patch isr_agreement_path( id: isa, params:{ isr_interface: { note: '' }, isr_agreement: { def_text: 'update definition' }, next_status_task: 1 })

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 7, isa.current_status
    assert_equal 2, isa.current_task

    # next: Task 5 Modify - to withdraw

    patch isr_agreement_path( id: isa, params:{ isr_interface: { note: '' }, isr_agreement: { def_text: 'update definition' }, next_status_task: 3 })

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 4, isa.current_status
    assert_equal 5, isa.current_task

    # next: close withdrawn

    patch isr_agreement_path( id: isa, params:{ isr_interface: { note: '' }, isr_agreement: { def_text: 'please withdraw' }, next_status_task: 2 })
    
    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 10, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 9, isa.current_status # closed - withdrawn
    assert_equal 6, isa.current_task   # workflow completed

  end

end
