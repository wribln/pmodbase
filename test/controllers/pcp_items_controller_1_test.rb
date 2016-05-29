require 'test_helper'
class PcpItemsController1Test < ActionController::TestCase
  tests PcpItemsController

  setup do
    @pcp_subject = pcp_subjects( :two )
    @account = accounts( :account_one )
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
    assert_equal @account, @account_p
    assert_equal 0, @pcp_subject.pcp_members.count
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

    # create item for further tests

    @pcp_item = @pcp_subject.pcp_items.new
    @pcp_item.author = 'tester'
    @pcp_item.description = 'test only'
    @pcp_item.seqno = 0
    @pcp_item.pcp_step = @pcp_subject.pcp_steps.most_recent.first
    assert_difference( 'PcpItem.count' )do
      assert @pcp_item.save, @pcp_item.errors.inspect
    end    

    # try to add response

    assert_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: {
        author: 'presenting party',
        description: 'Item 1 Response 1 by Presenting Party' },
        id: @pcp_item
    end
    assert_redirected_to pcp_item_path( assigns( :pcp_item ))

  end

end