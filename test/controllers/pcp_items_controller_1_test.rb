require 'test_helper'
class PcpItemsController1Test < ActionController::TestCase
  tests PcpItemsController

  # this performs tests starting with the presenting party

  setup do
    @pcp_subject = pcp_subjects( :two )
    @account_p = accounts( :one )
    @account_c = accounts( :two )
    session[ :current_user_id ] = @account_p.id
    assert @pcp_subject.pcp_members.destroy_all
  end

  # need two accounts in for the two different sides,
  # presenting and commenting party; start with
  # presenting party and no items

  test 'set up' do
    assert_equal 0, @pcp_subject.pcp_items.count
    assert_equal @pcp_subject.p_owner, @account_p
    assert_equal @pcp_subject.c_owner, @account_c
    assert_equal @pcp_subject.p_group_id, groups( :group_one ).id
    assert_equal @pcp_subject.c_group_id, groups( :group_two ).id
    assert_equal 0, @pcp_subject.pcp_members.count
    assert @pcp_subject.valid?, @pcp_subject.errors.inspect
    assert @pcp_subject.valid_subject?
  end

  test 'create pcp_items' do
  
    # presenting owner cannot create items

    assert_no_difference( 'PcpItem.count' ) do
      post :create, pcp_item: {
        author: 'presenting party',
        description: 'Item 1 by Presenting Party' },
        pcp_subject_id: @pcp_subject
    end
    assert_response :forbidden

    # must release current step in order to add PCP Items

    assert_difference( 'PcpStep.count', 1 )do
      current_controller = @controller
      @controller = PcpSubjectsController.new
      get :update_release, id: @pcp_subject
      @controller = current_controller 
    end
    @pcp_subject.reload
    assert @pcp_subject.valid_subject?
    assert_equal 0, @pcp_subject.current_step.subject_status

    # the following shall fail because presenter may not add PCP Items

    assert_no_difference( 'PcpItem.count' )do
      post :create, pcp_item: {
        author: 'presenter',
        description: 'Item 1 description' },
        pcp_subject_id: @pcp_subject
    end
    assert_response :forbidden

    # let the commenter do his job:

    @controller.reset_4_test
    switch_to_user( @account_c )

    assert_difference( 'PcpItem.count', 1 )do
      post :create, pcp_item: {
        author: 'commenter',
        description: 'Item 1 description' },
        pcp_subject_id: @pcp_subject
    end
    @pcp_subject = assigns( :pcp_subject )
    @pcp_item = assigns( :pcp_item )
    assert_redirected_to pcp_item_path( @pcp_item )
    refute_nil @pcp_item
    refute_nil @pcp_subject
    assert_equal 0, @pcp_subject.valid_subject?
    assert_equal 0, @pcp_item.valid_item?
    assert_equal 0, @pcp_subject.current_step.subject_status

    # prepare release, and release back to presenter ...
    # subject status is now open (1)

    assert_no_difference( 'PcpStep.count' )do
      @pcp_step = @pcp_subject.current_step
      current_controller = @controller
      @controller = PcpSubjectsController.new
      patch :update, id: @pcp_subject, 
        pcp_subject: { pcp_steps_attributes: {  '0' => { id: @pcp_step.id, report_version: 'B', new_assmt: '2' }}}
      @pcp_subject = assigns( :pcp_subject )
      @pcp_step = assigns( :pcp_curr_step )
      @pcp_subject.reload
      @pcp_step.reload
      assert_equal 1, @pcp_step.step_no
      assert_equal 2, @pcp_step.new_assmt
      assert_redirected_to pcp_subject_path( @pcp_subject )
      @controller = current_controller
    end
    @pcp_subject.reload
    assert_equal 0, @pcp_subject.valid_subject?
    assert_equal 0, @pcp_subject.current_step.subject_status

    assert_difference( 'PcpStep.count' )do
      current_controller = @controller
      @controller = PcpSubjectsController.new
      get :update_release, id: @pcp_subject
      @pcp_subject = assigns( :pcp_subject )
      @pcp_step = assigns( :pcp_curr_step )
      @pcp_subject.reload
      @pcp_step.reload
      assert_equal 1, @pcp_subject.current_step.subject_status
      assert_redirected_to pcp_release_doc_path( @pcp_subject, @pcp_step.step_no )
      @controller = current_controller
    end
    @pcp_subject.reload
    assert @pcp_subject.valid_subject?
    assert_equal 1, @pcp_subject.current_step.subject_status

    @controller.reset_4_test
    switch_to_user( @account_p )

    # check if current user can view the item

    get :show, id: @pcp_item
    assert_response :success

    # back at the presenter: add response to item

    assert_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'presenting party',
        description: 'Item 1 Response 1 by Presenting Party' },
        id: @pcp_item
      @pcp_comment = assigns( :pcp_comment )
      @pcp_item = assigns( :pcp_item )
    end
    assert_redirected_to pcp_item_path( @pcp_item )
    assert_equal 0, @pcp_item.valid_item?

    # add one more comment, make it public

    assert_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'presenting party',
        description: 'Item 1 Response 2 by Presenting Party',
        is_public: true },
        id: @pcp_item
    end

    @pcp_item = assigns( :pcp_item )
    assert_redirected_to pcp_item_path( @pcp_item )
    assert_equal 0, @pcp_item.valid_item?

    # add one last comment, not public!

    assert_difference( 'PcpComment.count', 1 ) do
      post :create_comment, pcp_comment: {
        author: 'presenting party',
        description: 'Item 1 Response 2 by Presenting Party',
        is_public: false },
        id: @pcp_item
    end
    @pcp_item = assigns( :pcp_item )
    @pcp_step = assigns( :pcp_step )
    refute_nil @pcp_item
    refute_nil @pcp_step
    assert_redirected_to pcp_item_path( @pcp_item )
    assert_equal 0, @pcp_item.valid_item?
    @pcp_subject = @pcp_item.pcp_subject
    assert_equal 0, @pcp_subject.valid_subject?
    refute @pcp_item.assessment_changed?( 0 )

    # release subject for closing by commenting party

    # prepare release, and release back to presenter ...
    # subject status is now open (1)

    assert_no_difference( 'PcpStep.count' )do
      @pcp_step = @pcp_subject.current_step
      current_controller = @controller
      @controller = PcpSubjectsController.new
      patch :update, id: @pcp_subject, 
        pcp_subject: { pcp_steps_attributes: {  '0' => { id: @pcp_step.id, report_version: 'C', subject_version: 'B' }}}
      @pcp_subject = assigns( :pcp_subject )
      @pcp_step = assigns( :pcp_curr_step )
      @pcp_subject.reload
      @pcp_step.reload
      assert_equal 2, @pcp_step.step_no
      assert_nil @pcp_step.new_assmt
      assert_redirected_to pcp_subject_path( @pcp_subject )
      @controller = current_controller
    end
    @pcp_subject.reload
    assert_equal 0, @pcp_subject.valid_subject?
    assert_equal 1, @pcp_subject.current_step.subject_status

    assert_difference( 'PcpStep.count' )do
      current_controller = @controller
      @controller = PcpSubjectsController.new
      get :update_release, id: @pcp_subject
      @pcp_subject = assigns( :pcp_subject )
      @pcp_step = assigns( :pcp_curr_step )
      @pcp_subject.reload
      @pcp_step.reload
      assert_equal 1, @pcp_subject.current_step.subject_status
      assert_redirected_to pcp_release_doc_path( @pcp_subject, @pcp_step.step_no )
      @controller = current_controller
    end
    @pcp_subject.reload
    assert @pcp_subject.valid_subject?
    assert_equal 1, @pcp_subject.current_step.subject_status

    @controller.reset_4_test
    switch_to_user( @account_c )

    # let commenter close item and subject

    assert_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'commenting party',
        description: 'Item 1 Closing Comment by Commenting Party',
        new_assmt: 2,
        is_public: true },
        id: @pcp_item
    end
    @pcp_item = assigns( :pcp_item )
    refute_nil @pcp_item
    @pcp_item.reload
    assert 0, @pcp_item.valid_item?

    assert_no_difference( 'PcpStep.count' )do
      @pcp_step = @pcp_subject.current_step
      current_controller = @controller
      @controller = PcpSubjectsController.new
      patch :update, id: @pcp_subject, 
        pcp_subject: { pcp_steps_attributes: {  '0' => { id: @pcp_step.id, report_version: 'D', new_assmt: '1' }}}
      @pcp_subject = assigns( :pcp_subject )
      @pcp_step = assigns( :pcp_curr_step )
      @pcp_subject.reload
      @pcp_step.reload
      assert_equal 3, @pcp_step.step_no
      assert_equal 1, @pcp_step.new_assmt
      assert_redirected_to pcp_subject_path( @pcp_subject )
      @controller = current_controller
    end
    @pcp_subject.reload
    assert_equal 0, @pcp_subject.valid_subject?
    assert_equal 1, @pcp_subject.current_step.subject_status

    assert_equal 1, @pcp_step.release_type

    # no new step when closing subject!

    assert_no_difference( 'PcpStep.count' )do
      current_controller = @controller
      @controller = PcpSubjectsController.new
      get :update_release, id: @pcp_subject
      @pcp_subject = assigns( :pcp_subject )
      @pcp_step = assigns( :pcp_curr_step )
      refute_nil @pcp_subject
      refute_nil @pcp_step
      @pcp_subject.reload
      @pcp_step.reload
      assert_equal 2, @pcp_subject.current_step.subject_status
      assert_redirected_to pcp_release_doc_path( @pcp_subject, @pcp_step.step_no )
      @controller = current_controller
    end
    assert @pcp_subject.valid_subject?
    assert @pcp_step.status_closed?

    # try to add items, comments by presenting group

    assert_no_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'presenting party',
        description: 'should fail - subject closed',
        is_public: true },
        id: @pcp_item
    end
    assert_response :unprocessable_entity
    @pcp_item = assigns( :pcp_item )
    refute_nil @pcp_item
    @pcp_item.reload
    assert 0, @pcp_item.valid_item?

  end

end