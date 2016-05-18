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

  test 'should create pcp_item' do
  
    # presenting owner may create pcp item now

    assert_difference( 'PcpItem.count' ) do
      post :create, pcp_item: {
        author: 'presenting party',
        description: 'Item 1 by Presenting Party' },
        pcp_subject_id: @pcp_subject
    end
    @pcp_item = assigns( :pcp_item )
    assert_redirected_to pcp_item_path( @pcp_item )

    # add a comment

    assert_difference( 'PcpComment.count' ) do
      post :create_comment, pcp_comment: { 
        author: 'presenting party',
        description: 'Comment 1 for Item 1' },
        id: @pcp_item
    end
    @pcp_comment = assigns( :pcp_comment )
    assert_redirected_to pcp_item_path( @pcp_item )

    # remove comment again

    assert_difference( 'PcpComment.count', -1 ) do
      delete :destroy_comment, id: @pcp_comment
    end
    @pcp_item = assigns( :pcp_item )
    assert_redirected_to pcp_item_path( @pcp_item )

    # remove item again

    assert_difference( 'PcpItem.count', -1 ) do
      delete :destroy, id: @pcp_item
    end
    @pcp_subject = assigns( :pcp_subject )
    assert_redirected_to pcp_subject_pcp_items_path( @pcp_subject )

  end

end