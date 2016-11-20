require 'test_helper'
class IsrInterfacesController0Test < ActionController::TestCase
  tests IsrInterfacesController

  setup do
    @isr_interface = isr_interfaces( :one )  
    @account = accounts( :one )
    session[ :current_user_id ] = @account.id
  end

  test 'check class attributes' do
    validate_feature_class_attributes FEATURE_ID_ISR_INTERFACES, 
      ApplicationController::FEATURE_ACCESS_VIEW,
      ApplicationController::FEATURE_CONTROL_GRPWF, 1
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :isr_interfaces )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create isr_interface' do
    assert_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: @isr_interface.title }
    end
    assert_redirected_to isr_interface_path( assigns( :isr_interface ))
  end

  test 'should fail to create isr_interface' do
    assert_no_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: { l_group_id: 0 }
    end
    assert_response :success
    isr = assigns( :isr_interface )
    refute isr.errors.empty?
  end

  test 'should show isr_interface' do
    get :show, id: @isr_interface
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @isr_interface
    assert_response :success
  end

  test 'should update isr_interface' do
    patch :update, id: @isr_interface, isr_interface: { 
      current_status: 1, current_task: 1, desc: @isr_interface.desc, safety_related: true }
    assert_redirected_to isr_interface_path( assigns( :isr_interface ))
  end

  test 'should fail to update isr_interface' do
    patch :update, id: @isr_interface, isr_interface: { l_group_id: 0 }
    assert_response :success
    isr = assigns( :isr_interface )
    refute isr.errors.empty?
  end

  test 'should destroy isr_interface' do
    assert_difference( 'IsrInterface.count', -1) do
      delete :destroy, id: @isr_interface
    end
    assert_redirected_to isr_interfaces_path
  end

end
