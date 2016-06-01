require 'test_helper'
class PcpItemsController1Test < ActionController::TestCase
  tests PcpItemsController

  # this performs tests starting with the presenting party

  setup do
    @pcp_subject = pcp_subjects( :two )
    @account_p = accounts( :account_one )
    @account_c = accounts( :account_two )
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
    assert_equal 0, @pcp_subject.pcp_members.count
    assert @pcp_subject.valid?, @pcp_subject.errors.inspect
    assert @pcp_subject.valid_subject?
  end

  test 'create pcp_item' do
  
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
    @controller.delete_user

    session[ :current_user_id ] = @account_c.id

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
    assert_equal 0, @pcp_item.valid_item?
    assert_equal 0, @pcp_subject.valid_subject?

    # add comment to newly created item

    assert_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'presenting party',
        description: 'Item 1 Response 1 by Presenting Party' },
        id: @pcp_item
    end
    @pcp_item = assigns( :pcp_item )
    assert_redirected_to pcp_item_path( @pcp_item )
    assert_equal 0, @pcp_item.valid_item?

    # add one more comment, make it public

    assert_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'presenting party',
        description: 'Item 1 Response 2 by Presenting Party',
        is_public: true,
        assessment: 1 },
        id: @pcp_item
    end

    @pcp_item = assigns( :pcp_item )
    assert_redirected_to pcp_item_path( @pcp_item )
    assert_equal 0, @pcp_item.valid_item?

    # attempt one more comment, try to close item

    assert_no_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'presenting party',
        description: 'Item 1 Response 2 by Presenting Party',
        is_public: true,
        assessment: 2 },
        id: @pcp_item
    end
    @pcp_item = assigns( :pcp_item )
    puts @pcp_items.errors.inspect
    assert_redirected_to pcp_item_path( @pcp_item )
    assert_equal 0, @pcp_item.valid_item?

  end

end