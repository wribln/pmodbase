require 'test_helper'
class IsrInterfacesController3Test < ActionController::TestCase
  tests IsrInterfacesController

  # try steps in workflow 1 - create revision

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

  test 'test workflow 1a' do

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

    # create associated agreement - should fail as revision is
    # only possible on an existing agreement

    assert_no_difference( 'IsrAgreement.count' )do
      post :create_ia, id: isf, isr_interface: { note: '' },
        isr_agreement: { ia_type: '1',
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id,
        def_text: 'test definition' }
    end
    isf = assigns( :isr_interface )
    refute_nil isf
    isa = assigns( :isr_agreement )
    refute_nil isa
    assert_response :success
    assert_includes isa.errors, :ia_type

  end

  test 'test workflow 1b: revise agreement' do

    @isr_agreement.ia_status = 1
    assert @isr_agreement.save
    
    assert_difference( 'IsrAgreement.count', 1 )do
      post :create_ia, id: @isr_interface, isr_interface: { note: '' },
        isr_agreement: { ia_type: '1', based_on_id: @isr_agreement,
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
    assert_equal 1, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 4, isa.based_on.ia_status
    assert_equal 0, isf.if_status
    assert_equal 0, isa.current_status
    assert_equal 1, isa.current_task

    # next: Task 1 Prepare

    patch :update_ia, id: isa,
      isr_interface: { note: '' },
      isr_agreement: { def_text: 'next task: prepare', l_owner_id: @account.id }, next_status_task: 1
    assert_redirected_to isr_agreement_details_path( isa )

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 1, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 4, isa.based_on.ia_status
    assert_equal 0, isf.if_status
    assert_equal 1, isa.current_status
    assert_equal 2, isa.current_task

    # next: Task 1 Prepare in progress

    patch :update_ia, id: isa,
      isr_interface: { note: '' },
      isr_agreement: { def_text: 'still prepare' }, next_status_task: 1
    assert_redirected_to isr_agreement_details_path( isa )

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 1, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 4, isa.based_on.ia_status
    assert_equal 0, isf.if_status
    assert_equal 2, isa.current_status
    assert_equal 2, isa.current_task

    # next: Task 2 Confirm

    patch :update_ia, id: isa,
      isr_interface: { note: '' },
      isr_agreement: { def_text: 'update definition', p_owner_id: @account.id }, next_status_task: 2

    isa.reload
    isf.reload
    assert_equal 1, isa.ia_no
    assert_equal 1, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 4, isa.based_on.ia_status
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
    assert_equal 1, isa.rev_no
    assert_equal 0, isa.ia_status
    assert_equal 4, isa.based_on.ia_status
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
    assert_equal 1, isa.rev_no
    assert_equal 1, isa.ia_status # agreed
    assert_equal 2, isf.if_status # defined - frozen
    assert_equal 6, isa.based_on.ia_status # superseeded
    assert_equal 8, isa.current_status # agreed
    assert_equal 6, isa.current_task   # workflow completed

  end

end
