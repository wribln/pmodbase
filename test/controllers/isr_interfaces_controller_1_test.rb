require 'test_helper'
class IsrInterfacesController1Test < ActionController::TestCase
  tests IsrInterfacesController

  setup do
    @isr_interface = isr_interfaces( :one )  
    @account = accounts( :one )
    session[ :current_user_id ] = @account.id
  end

  # traverse workflow

  test 'standard workflow' do

    # create interface, identify

    assert_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: @isr_interface.title }
    end
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

    # definition in progress, Define

    patch :update, id: new_isr, next_status_task: 1
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 2, new_isr.current_status
    assert_equal 2, new_isr.current_task

    # request update by IFM, Update

    patch :update, id: new_isr, next_status_task: 3
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 6, new_isr.current_status
    assert_equal 6, new_isr.current_task

    # identification updated, Define

    patch :update, id: new_isr, next_status_task: 1
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 7, new_isr.current_status
    assert_equal 2, new_isr.current_task

    # definition released, Confirm Definition

    patch :update, id: new_isr, next_status_task: 2
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 3, new_isr.current_status
    assert_equal 3, new_isr.current_task

    # reject definition, Define

    patch :update, id: new_isr, commit: I18n.t( 'isr_interfaces.edit.reject' )
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 9, new_isr.current_status
    assert_equal 2, new_isr.current_task

    # definition released, Confirm Definition

    patch :update, id: new_isr, next_status_task: 2
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 3, new_isr.current_status
    assert_equal 3, new_isr.current_task

    # confirm definition, Archive IF Status    

    patch :update, id: new_isr, commit: I18n.t( 'isr_interfaces.edit.confirm' )
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 4, new_isr.current_status
    assert_equal 4, new_isr.current_task

    # defined, Process IAs

    patch :update, id: new_isr, next_status_task: 1
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 5, new_isr.current_status
    assert_equal 5, new_isr.current_task

    # attempt to edit

    patch :edit, id: new_isr
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal I18n.t( 'isr_interfaces.msg.no_edit_now' ), flash[ :notice ]

  end

  test 'close - not applicable' do

    # create interface, identify

    assert_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: @isr_interface.title }
    end
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 0, new_isr.current_status
    assert_equal 1, new_isr.current_task

    # close - not applicable

    patch :update, id: new_isr, next_status_task: 2
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 10, new_isr.current_status
    assert_equal 8, new_isr.current_task

    # attempt to edit

    patch :edit, id: new_isr
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal I18n.t( 'isr_interfaces.msg.no_edit_now' ), flash[ :notice ]

  end

  test 'close - withdrawn' do

    # create interface, identify

    assert_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: @isr_interface.title }
    end
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 0, new_isr.current_status
    assert_equal 1, new_isr.current_task

    # identified, Define

    patch :update, id: new_isr, isr_interface: { desc: @isr_interface.desc, safety_related: true }, next_status_task: 1
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 1, new_isr.current_status
    assert_equal 2, new_isr.current_task

    # request withdrawal, Withdraw

    patch :update, id: new_isr, next_status_task: 4
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 8, new_isr.current_status
    assert_equal 7, new_isr.current_task

    # close - withdraw

    patch :update, id: new_isr, next_status_task: 1
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal 11, new_isr.current_status
    assert_equal 8, new_isr.current_task

    # attempt to edit

    patch :edit, id: new_isr
    new_isr = assigns( :isr_interface )
    assert_redirected_to isr_interface_path( new_isr )
    assert_equal I18n.t( 'isr_interfaces.msg.no_edit_now' ), flash[ :notice ]

  end

end
