require 'test_helper'
class IsrInterfacesController1Test < ActionController::TestCase
  tests IsrInterfacesController

  # try steps in workflow 0 - standard path: creation to agreed

  setup do
    @isr_interface = isr_interfaces( :one ) 
    @isr_agreement = isr_agreements( :one )
    @account = accounts( :one )
    session[ :current_user_id ] = @account.id
  end

  test 'test workflow 0' do

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
    assert 0, isf.if_status

    # create associated agreement

    assert_difference( 'IsrAgreement.count', 1 )do
      post :create_ia, id: isf, isr_interface: { note: '' },
        isr_agreement: { ia_type: '0',
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id,
        def_text: 'test definition' }
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

    # update to same status

    patch :update_ia, id: isa,
      isr_interface: { note: '' },
      isr_agreement: { desc: 'update definition' }, next_status_task: 0
    assert_redirected_to isr_agreement_details_path( isa )

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 0, isa.current_status
    assert_equal 1, isa.current_task

    # next: Task 1 Prepare

    patch :update_ia, id: isa,
      isr_interface: { note: '' },
      isr_agreement: { desc: 'next task: prepare' }, next_status_task: 1
    assert_redirected_to isr_agreement_details_path( isa )

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 1, isa.current_status
    assert_equal 2, isa.current_task

    # next: Task 1 Prepare in progress

    patch :update_ia, id: isa,
      isr_interface: { note: '' },
      isr_agreement: { desc: 'still prepare' }, next_status_task: 1
    assert_redirected_to isr_agreement_details_path( isa )

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 0, isf.if_status
    assert_equal 2, isa.current_status
    assert_equal 2, isa.current_task

    # next: Task 2 Confirm

    patch :update_ia, id: isa,
      isr_interface: { note: '' },
      isr_agreement: { desc: 'update definition' }, next_status_task: 2

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 2, isf.if_status
    assert_equal 3, isa.current_status
    assert_equal 3, isa.current_task

    # next: Task 4 Archive

    patch :update_ia, id: isa,
      commit: I18n.t( 'isr_interfaces.edit.confirm' ),
      isr_interface: { note: '' }

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 2, isf.if_status
    assert_equal 5, isa.current_status
    assert_equal 4, isa.current_task

    # next: agreed

    patch :update_ia, id: isa,
      isr_interface: { note: '' },
      next_status_task: 1
    
    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 0, isa.rev_no
    assert_equal 1, isa.ia_status
    assert_equal 2, isf.if_status
    assert_equal 8, isa.current_status # agreed
    assert_equal 6, isa.current_task   # workflow completed

  end

end
