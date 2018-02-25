require 'test_helper'
class IsrInterfacesController6Test < ActionDispatch::IntegrationTest

  # need four test accounts:
  # IFM, IFP, IFL and one other

  setup do
    @isr_interface = isr_interfaces( :one ) 
    @isr_agreement = isr_agreements( :one )
    @a_ifm = accounts( :one )
    pg = @a_ifm.permission4_groups.where( feature_id: FEATURE_ID_ISR_INTERFACES )
    pg[ 0 ].to_read = 2
    pg[ 0 ].to_update = 2
    pg[ 0 ].to_create = 2
    assert pg[ 0 ].save, pg[ 0 ].errors.messages

    @a_ifl = accounts( :two )
    pg = @a_ifl.permission4_groups.build( feature_id: FEATURE_ID_ISR_INTERFACES, group_id: 0, to_read: 1, to_update: 1 )
    assert pg.save, pg.errors.messages

    @a_ifp = accounts( :three )
    pg = @a_ifp.permission4_groups.build( feature_id: FEATURE_ID_ISR_INTERFACES, group_id: 0, to_read: 1, to_update: 1 )
    assert pg.save, pg.errors.messages

    @a_wop = accounts( :wop )
    signon_by_user @a_wop
  end

  test 'new if - only ifm' do
    [ @a_ifl, @a_ifp, @a_ifm ].each do |aa|
      get new_isr_interface_path
      check_for_cr
      switch_to_user( aa )
    end
    get new_isr_interface_path
    assert_response :success
  end

  test 'new_ia - only ifm' do
    [ @a_ifl, @a_ifp, @a_ifm ].each do |aa|
      get new_isr_agreement_path( id: @isr_interface )
      check_for_cr
      switch_to_user( aa )
    end
    get new_isr_agreement_path( id: @isr_interface )
    assert_response :success
  end

  test 'create if - only ifm' do
    [ @a_ifl, @a_ifp, @a_ifm ].each do |aa|
      assert_no_difference( 'IsrInterface.count' ) do
        post isr_interfaces_path( params:{ isr_interface: {
          l_group_id: @isr_interface.l_group_id,
          p_group_id: @isr_interface.p_group_id, 
          title: 'new interface' }})
      end
      check_for_cr
      switch_to_user( aa )
    end
    assert_difference( 'IsrInterface.count' ) do
      post isr_interfaces_path( params:{ isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: 'new interface by ifm' }})
    end
    assert_redirected_to isr_interface_details_path( assigns( :isr_interface ))
  end

  test 'create ia - only ifm' do
    [ @a_ifl, @a_ifp, @a_ifm ].each do |aa|
      assert_no_difference( 'IsrAgreement.count' ) do
        post isr_agreement_path( id: @isr_interface, params:{ isr_interface: { note: '' },
          isr_agreement: { ia_type: '0',
          l_group_id: @isr_interface.l_group_id,
          p_group_id: @isr_interface.p_group_id,
          def_text: 'test definition' }})
      end
      check_for_cr
      switch_to_user( aa )
    end
    assert_difference( 'IsrAgreement.count' ) do
      post isr_agreement_path( id: @isr_interface, params:{ isr_interface: { note: '' },
        isr_agreement: { ia_type: '0',
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id,
        def_text: 'test definition' }})
    end
    assert_redirected_to isr_agreement_details_path( assigns( :isr_agreement ))
  end

  test 'update if - only ifm' do
    # wop
    patch isr_interface_path( id: @isr_interface, params:{ isr_interface: { desc: 'test description', safety_related: true }})
    check_for_cr
    # ifl, ifp
    [ @a_ifl, @a_ifp ].each do |aa|
      switch_to_user( aa )
      patch isr_interface_path( id: @isr_interface, params:{ isr_interface: { desc: 'test description', safety_related: true }})
      assert_response :forbidden
    end
    # ifm
    switch_to_user( @a_ifm )
    patch isr_interface_path( id: @isr_interface, params:{ isr_interface: { desc: 'test description', safety_related: true }})
    assert_redirected_to isr_interface_details_path( @isr_interface )
  end

  test 'update ia - each task' do
    assert 0, @isr_agreement.current_status
    assert 0, @isr_agreement.ia_type

    # task - 0, 1 - by ifm

    [ 0, 1 ].each do |ct|

      assert_equal ct, @isr_agreement.current_task
  
      # wop
      patch isr_agreement_path( id: @isr_agreement, params:{
        isr_interface: { note: '' },
        isr_agreement: { def_text: 'next task: prepare', l_owner_id: @a_ifl.id }, next_status_task: 1 })
      check_for_cr
      # ifl, ifp
      [ @a_ifl, @a_ifp ].each do |aa|
        switch_to_user( aa )
        patch isr_agreement_path( id: @isr_agreement, params:{
          isr_interface: { note: '' },
          isr_agreement: { def_text: 'next task: prepare', l_owner_id: @a_ifl.id }, next_status_task: 1 })
        assert_response :forbidden
      end
      # ifm
      switch_to_user( @a_ifm )
      patch isr_agreement_path( id: @isr_agreement, params:{
        isr_interface: { note: '' },
        isr_agreement: { def_text: 'next task: prepare', l_owner_id: @a_ifl.id }, next_status_task: 1 })
      assert_redirected_to isr_agreement_details_path( @isr_agreement )
      @isr_agreement.reload
      switch_to_user( @a_wop )
    
    end

    # task - 2 - by ifl

    assert_equal 2, @isr_agreement.current_task

    # wop
    patch isr_agreement_path( id: @isr_agreement, params:{
      isr_interface: { note: '' },
      isr_agreement: { def_text: 'next task: confirm', p_owner_id: @a_ifp.id }, next_status_task: 3 })
    check_for_cr

    [ @a_ifp, @a_ifm ].each do |aa|
      switch_to_user( aa )
      patch isr_agreement_path( id: @isr_agreement, params:{
        isr_interface: { note: '' },
        isr_agreement: { def_text: 'next task: confirm', p_owner_id: @a_ifp.id }, next_status_task: 3 })
      assert_response :forbidden
    end

    switch_to_user( @a_ifl )
    patch isr_agreement_path( id: @isr_agreement, params:{
      isr_interface: { note: '' },
      isr_agreement: { def_text: 'next task: confirm', p_owner_id: @a_ifp.id }, next_status_task: 3 })
    assert_redirected_to isr_agreement_details_path( @isr_agreement )
    @isr_agreement.reload

    # task - 5 - by ifm

    assert_equal 5, @isr_agreement.current_task
    assert_equal 4, @isr_agreement.current_status

    # wop
    switch_to_user( @a_wop )
    patch isr_agreement_path( id: @isr_agreement, params:{
      isr_interface: { note: '' },
      isr_agreement: { def_text: 'modified' }, next_status_task: 1 })
    check_for_cr
    
    [ @a_ifl, @a_ifp ].each do |aa|
      switch_to_user( aa )
      patch isr_agreement_path( id: @isr_agreement, params:{
        isr_interface: { note: '' },
        isr_agreement: { def_text: 'modified' }, next_status_task: 1 })
      assert_response :forbidden
    end

    switch_to_user( @a_ifm )
    patch isr_agreement_path( id: @isr_agreement, params:{
      isr_interface: { note: '' },
      isr_agreement: { def_text: 'modified' }, next_status_task: 1 })
    assert_redirected_to isr_agreement_details_path( @isr_agreement )
    @isr_agreement.reload

    # repeat task 2 - by ifl

    assert_equal 2, @isr_agreement.current_task
    assert_equal 7, @isr_agreement.current_status

    switch_to_user( @a_ifl )
    patch isr_agreement_path( id: @isr_agreement, params:{
      isr_interface: { note: '' },
      isr_agreement: { def_text: 'next task: confirm', p_owner_id: @a_ifp.id }, next_status_task: 2 })
    assert_redirected_to isr_agreement_details_path( @isr_agreement )
    @isr_agreement.reload

    # task - 3 - by ifp

    assert_equal 3, @isr_agreement.current_task
    assert_equal 3, @isr_agreement.current_status

    switch_to_user( @a_wop )
    patch isr_agreement_path( id: @isr_agreement, params:{ commit: I18n.t( 'isr_interfaces.edit.confirm' ), isr_interface: { note: '' }})
    check_for_cr

    [ @a_ifl, @a_ifm ].each do |aa|
      switch_to_user( aa )
      patch isr_agreement_path( id: @isr_agreement, params:{ commit: I18n.t( 'isr_interfaces.edit.confirm' ), isr_interface: { note: '' }})
      assert_response :forbidden
    end

    switch_to_user( @a_ifp )
    patch isr_agreement_path( id: @isr_agreement, params:{ commit: I18n.t( 'isr_interfaces.edit.confirm' ), isr_interface: { note: '' }})
    assert_redirected_to isr_agreement_path( @isr_agreement )
    @isr_agreement.reload

    # task - 4 - by ifm

    assert_equal 4, @isr_agreement.current_task
    assert_equal 5, @isr_agreement.current_status

    switch_to_user( @a_wop )
    patch isr_agreement_path( id: @isr_agreement, params:{ isr_interface: { note: '' }, next_status_task: 1 })
    check_for_cr

    [ @a_ifl, @a_ifp ].each do |aa|
      switch_to_user( @a_ifl )
      patch isr_agreement_path( id: @isr_agreement, params:{ isr_interface: { note: '' }, next_status_task: 1 })
      assert_response :forbidden
    end

    switch_to_user( @a_ifm )
    patch isr_agreement_path( id: @isr_agreement, params:{ isr_interface: { note: '' }, next_status_task: 1 })
    assert_redirected_to isr_agreement_details_path( @isr_agreement )
    @isr_agreement.reload

    # final task: none

    assert_equal 6, @isr_agreement.current_task
    assert_equal 8, @isr_agreement.current_status

    switch_to_user( @a_wop )
    patch isr_agreement_path( id: @isr_agreement, params:{ isr_interface: { note: '' }, next_status_task: 1 })
    check_for_cr

    [ @a_ifm, @a_ifl, @a_ifp ].each do |aa|

      switch_to_user( aa )
      patch isr_agreement_path( id: @isr_agreement, params:{ isr_interface: { note: '' }, next_status_task: 1 })
      assert_response :forbidden
    end

  end

end
