require 'test_helper'
class PcpItemsController2Test < ActionController::TestCase
  tests PcpItemsController

  setup do
    @pcp_subject = pcp_subjects( :two )
    @account = accounts( :account_two )
    @account_p = accounts( :account_one )
    @account_c = accounts( :account_two )
    session[ :current_user_id ] = @account.id
    assert @pcp_subject.pcp_members.destroy_all
  end

  # need two accounts in for the two different sides,
  # presenting and commenting party; start with
  # presenting party and no items

  test 'set up' do
    assert_equal 0, @pcp_subject.pcp_items.count
    assert_equal @pcp_subject.p_owner, @account_p
    assert_equal @pcp_subject.c_owner, @account_c
    assert_equal @account, @account_c
    assert_equal 0, @pcp_subject.pcp_members.count
  end

  # other party should not be able to add items now

  test 'should not create pcp_item' do
    assert_no_difference( 'PcpItem.count' ) do
      post :create, pcp_item: {
        author: 'commenting party',
        description: 'Item 1 by Commenting Party' },
        pcp_subject_id: @pcp_subject
    end
    assert_response :forbidden

    # create item for further tests

    @pcp_item = @pcp_subject.pcp_items.new
    @pcp_item.author = 'tester'
    @pcp_item.description = 'test only'
    @pcp_item.seqno = 0
    @pcp_item.pcp_step = @pcp_subject.pcp_steps.most_recent.first
    assert_difference( 'PcpItem.count' )do
      assert @pcp_item.save, @pcp_item.errors.inspect
    end    

    # try to add comment - should fail

    assert_no_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'commenting party',
        description: 'Item 1 Comment 1 by Commenting Party' },
        id: @pcp_item
    end
    assert_response :forbidden

    # add comment for further tests

    @pcp_comment = @pcp_item.pcp_comments.new
    @pcp_comment.author = 'tester'
    @pcp_comment.description = 'test only'
    @pcp_comment.pcp_step = @pcp_item.pcp_step
    assert_difference( 'PcpComment.count' )do
      assert @pcp_comment.save, @pcp_comment.errors.inspect
    end

    # attempt to delete comment

    assert_no_difference( 'PcpComment.count' )do
      delete :destroy_comment, id: @pcp_comment
    end
    assert_response :forbidden

    # a good situation to remove item plus comment

    assert_difference([ 'PcpComment.count', 'PcpItem.count' ], -1 )do
      @pcp_item.destroy
    end

  end

end