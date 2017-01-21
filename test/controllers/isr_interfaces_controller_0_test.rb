require 'test_helper'
class IsrInterfacesController0Test < ActionController::TestCase
  tests IsrInterfacesController

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

  test 'check class attributes' do
    validate_feature_class_attributes FEATURE_ID_ISR_INTERFACES, 
      ApplicationController::FEATURE_ACCESS_VIEW,
      ApplicationController::FEATURE_CONTROL_GRPWF, 5
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :isr_interfaces )
  end

  test 'should show isr_interface' do
    get :show, id: @isr_interface
    assert_response :success  
  end

  test 'should show all' do
    get :show_all, id: @isr_interface
    assert_response :success
  end

  test 'should show ia' do
    get :show_ia, id: @isr_agreement
    assert_response :success
  end

  test 'should show ia all' do
    get :show_ia_all, id: @isr_agreement
    assert_response :success
  end

  test 'should show ia icf' do
    get :show_ia_icf, id: @isr_agreement
    assert_response :success
  end

  test 'should get new if' do
    get :new
    assert_response :success
    isf = assigns( :isr_interface )
    refute_nil isf
  end

  test 'should get new ia' do
    get :new_ia, id: @isr_interface
    assert_response :success
    isf = assigns( :isr_interface )
    isa = assigns( :isr_agreement )
    refute_nil isf
    refute_nil isa
    assert_equal isf.id, @isr_interface.id
    assert_equal isa.isr_interface.id, isf.id
  end

  test 'should get ia copy' do
    get :new_ia, id: @isr_agreement, wt: 0
    assert_response :success
    isf = assigns( :isr_interface )
    isa = assigns( :isr_agreement )
    refute_nil isf
    refute_nil isa
    assert_equal isf.id, @isr_interface.id
    assert_equal isa.isr_interface.id, isf.id
    assert_nil isa.based_on_id
  end

  test 'should get revised ia' do

    # first attempt fails due to wrong status (must be agreed)

    get :new_ia, id: @isr_agreement, wt: 1
    isa = assigns( :isr_agreement )
    refute_nil isa
    assert_response :unprocessable_entity

    isa.based_on.ia_status = 1
    assert isa.save #, isa.errors.messages

    get :new_ia, id: @isr_agreement, wt: 1
    assert_response :success
    isf = assigns( :isr_interface )
    isa = assigns( :isr_agreement )
    refute_nil isf
    refute_nil isa
  end

  test 'should get termination ia' do

    # first attempt fails due to wrong status (must be agreed)

    get :new_ia, id: @isr_agreement, wt: 2
    isa = assigns( :isr_agreement )
    refute_nil isa
    assert_response :unprocessable_entity

    isa.based_on.ia_status = 1
    assert isa.save, isa.errors.messages

    get :new_ia, id: @isr_agreement, wt: 2
    assert_response :success
    isf = assigns( :isr_interface )
    isa = assigns( :isr_agreement )
    refute_nil isf
    refute_nil isa
  end

  test 'should get edit' do
    get :edit, id: @isr_interface
    assert_response :success
  end

  test 'should get edit ia' do
    get :edit_ia, id: @isr_agreement
    assert_response :success
  end

  test 'should update interface' do
    patch :update, id: @isr_interface, isr_interface: { desc: 'test description', safety_related: true }
    isr = assigns( :isr_interface )
    refute_nil isr
    assert_equal 'test description', isr.desc
    assert_redirected_to isr_interface_details_path( isr )
  end

  test 'should fail to update isr interface' do
    patch :update, id: @isr_interface, isr_interface: { l_group_id: 0 }
    assert_response :success
    isr = assigns( :isr_interface )
    refute isr.errors.empty?
  end

  test 'should update agreement' do
    patch :update_ia, id: @isr_agreement,
      isr_interface: { note: 'test note' }, 
      isr_agreement: { def_text: 'test description' }, next_status_task: 0
    isr = assigns( :isr_interface )
    refute_nil isr
    assert_equal 'test note', isr.note
    isa = assigns( :isr_agreement )
    refute_nil isa
    assert_equal 'test description', isa.def_text
    assert_redirected_to isr_agreement_details_path( isa )
  end

  test 'should fail to update isr agreement' do
    patch :update_ia, id: @isr_agreement, 
      isr_interface: { note: nil },
      isr_agreement: { p_group_id: 0 }, next_status_task: 0
    isa = assigns( :isr_agreement )
    assert_response :success
    refute isa.errors.empty?
  end

  test 'should create isr interface' do
    assert_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: {
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id, 
        title: @isr_interface.title }
    end
    isr = assigns( :isr_interface )
    refute_nil isr
    assert_redirected_to isr_interface_details_path( isr )
  end

  test 'should fail to create isr_interface' do
    assert_no_difference( 'IsrInterface.count' ) do
      post :create, isr_interface: { l_group_id: 0 }
    end
    assert_response :success
    isr = assigns( :isr_interface )
    refute isr.errors.empty?
  end

  test 'should create isr agreement' do
    assert_difference( 'IsrAgreement.count', 1 )do
      post :create_ia, id: @isr_interface, isr_interface: { note: '' },
        isr_agreement: { ia_type: 0,
        l_group_id: @isr_interface.l_group_id,
        p_group_id: @isr_interface.p_group_id,
        def_text: 'test definition' }
    end
    isr = assigns( :isr_interface )
    refute_nil isr
    isa = assigns( :isr_agreement )
    refute_nil isa
    assert_redirected_to isr_agreement_details_path( isa )
    assert_equal 2, isa.ia_no
    assert_equal 'test definition', isa.def_text
  end

  test 'should fail to create isr_agreement' do
    assert_no_difference( 'IsrInterface.count' ) do
      post :create_ia, id: @isr_interface, isr_interface: { note: '' }, isr_agreement: { ia_type: 0, l_group_id: 0 }
    end
    assert_response :success
    isr = assigns( :isr_interface )
    refute_nil isr
    isa = assigns( :isr_agreement )
    refute_nil isa
    refute isa.errors.empty?
  end

  test 'should destroy isr_interface' do
    assert_difference( 'IsrInterface.count', -1) do
      delete :destroy, id: @isr_interface
    end
    assert_redirected_to isr_interfaces_path
  end

end
