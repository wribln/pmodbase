require 'test_helper'
class IsrInterfacesController2Test < ActionController::TestCase
  tests IsrInterfacesController

  setup do
    @isr_interface = isr_interfaces( :one )
    @account = accounts( :wop )
    session[ :current_user_id ] = @account.id
  end

  test 'index, show, print is permitted for all, other actions not' do

    get :index
    assert_response :success

    get :show, id: @isr_interface
    assert_response :success

    get :show_icf, id: @isr_interface
    assert_response :success

    assert_no_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: @isr_interface.title }
    end
    check_for_cr

    get :edit, id: @isr_interface
    check_for_cr

    patch :update, id: @isr_interface, isr_interface: { desc: @isr_interface.desc, safety_related: true }, next_status_task: 1
    check_for_cr

    assert_no_difference( 'IsrInterface.count' ) do
      delete :destroy, id: @isr_interface
    end
    check_for_cr

  end

  # traverse workflow with roles

  test 'standard workflow' do

    # setup accounts and permissions

    p = people( :person_one )
    g1 = @isr_interface.l_group
    g2 = @isr_interface.p_group

    a_ifm = Account.new( name: 'Interface_Manager', password: 'Test-pw1', person_id: p.id )
    assert a_ifm.save, a_ifm.errors.inspect

    a_ifl = Account.new( name: 'Interface_Leader', password: 'Test-pw1', person_id: p.id )
    assert a_ifl.save, a_ifl.errors.inspect

    a_ifp = Account.new( name: 'Interface_Partner', password: 'Test-pw1', person_id: p.id )
    assert a_ifp.save, a_ifp.errors.inspect

    p = Permission4Group.new( account_id: a_ifm.id, feature_id: FEATURE_ID_ISR_INTERFACES, group_id: g1.id, 
      to_index: 1, to_read: 1, to_create: 1, to_update: 1 )
    assert p.save, p.errors.inspect
    assert a_ifm.permission_to_access( FEATURE_ID_ISR_INTERFACES, :to_create )

    p = Permission4Group.new( account_id: a_ifm.id, feature_id: FEATURE_ID_ISR_INTERFACES, group_id: g2.id,
      to_index: 1, to_read: 1, to_create: 1, to_update: 1 )
    assert p.save, p.errors.inspect

    p = Permission4Group.new( account_id: a_ifl.id, feature_id: FEATURE_ID_ISR_INTERFACES, group_id: g1.id,
      to_index: 1, to_read: 1, to_update: 1 )
    assert p.save, p.errors.inspect

    p = Permission4Group.new( account_id: a_ifp.id, feature_id: FEATURE_ID_ISR_INTERFACES, group_id: g2.id, 
      to_index: 1, to_read: 1, to_update: 1 )
    assert p.save, p.errors.inspect

    p = Permission4Flow.new( account_id: a_ifm.id, feature_id: FEATURE_ID_ISR_INTERFACES, workflow_id: 0,
      label: 'IFM', tasklist: '0,1,4,5,6,7' )
    assert p.save, p.errors.inspect

    p = Permission4Flow.new( account_id: a_ifl.id, feature_id: FEATURE_ID_ISR_INTERFACES, workflow_id: 0,
      label: 'IFL', tasklist: '2' )
    assert p.save, p.errors.inspect

    p = Permission4Flow.new( account_id: a_ifp.id, feature_id: FEATURE_ID_ISR_INTERFACES, workflow_id: 0, 
      label: 'IFP', tasklist: '3' )
    assert p.save, p.errors.inspect

    # create interface, identify

    [ a_ifl, a_ifp ].each do |a|
      switch_to_user( a )
      assert_no_difference( 'IsrInterface.count' ) do
        post :create, isr_interface: { l_group_id: g1.id, p_group_id: g2.id, title: 'test' }
      end
      check_for_cr
    end

    switch_to_user( a_ifm )
    assert_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: { l_group_id: g1.id, p_group_id: g2.id, title: 'test' }
    end
    isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( isr )

    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 0, new_isr.current_status
    assert_equal 1, new_isr.current_task

    get :show, id: new_isr.id
    assert_response :success

    get :edit, id: new_isr.id
    assert_response :success

    # identified, Define

    patch :update, id: new_isr, isr_interface: { desc: @isr_interface.desc, safety_related: true }, next_status_task: 1
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 1, new_isr.current_status
    assert_equal 2, new_isr.current_task

    # definition in progress, Define by IFL

    [ a_ifp, a_ifl ].each do |a|
      patch :update, id: new_isr, next_status_task: 1
      new_isr = assigns( :isr_interface )
      assert_redirected_to isr_interface_path( new_isr )
      assert_equal I18n.t( 'isr_interfaces.msg.you_no_edit' ), flash[ :notice ]
      assert_equal 1, new_isr.current_status
      assert_equal 2, new_isr.current_task
      switch_to_user( a )
    end

    patch :update, id: new_isr, next_status_task: 1
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 2, new_isr.current_status
    assert_equal 2, new_isr.current_task

  end

end
