require 'test_helper'
class PcpItemsController2Test < ActionDispatch::IntegrationTest

  # tests on closed subject

  setup do
    @pcp_subject = pcp_subjects( :two )
    @account_p = accounts( :one )
    @account_c = accounts( :two )
    signon_by_user @account_p   
    assert @pcp_subject.pcp_members.destroy_all
  end

  [ '1', '4' ].each do |final_assessment|

  test "closed subjects with final assessment = #{ final_assessment }" do

    # using subject :two which was not yet released

    @pcp_step = @pcp_subject.current_step
    refute @pcp_step.status_closed?
    assert_equal 0, @pcp_step.release_type # yes we can release step
    assert @pcp_step.in_presenting_group?

    # release to commenting party

    assert_difference( 'PcpStep.count' )do
      get pcp_subject_release_path( id: @pcp_subject )
    end
    @pcp_subject = assigns( :pcp_subject )
    @pcp_step = @pcp_subject.current_step
    assert_redirected_to pcp_release_doc_path( @pcp_subject, @pcp_subject.previous_step.step_no )

    # commenting party makes release w/ just 1 item and 1 comment

    switch_to_user @account_c

    assert_difference( 'PcpItem.count', 1 )do
      post pcp_subject_pcp_items_path( pcp_subject_id: @pcp_subject, params:{ pcp_item: {
        author: 'commenter',
        description: 'Nice work!' }})
    end
    @pcp_item = assigns( :pcp_item )
    assert_redirected_to pcp_item_path( @pcp_item )

    assert_difference( 'PcpComment.count', 1 )do
      post create_pcp_comment_path( id: @pcp_item, params:{ pcp_comment: {
        author: 'commenter',
        description: 'Really!',
        is_public: true }})
    end
    @pcp_comment = assigns( :pcp_comment )
    refute_nil @pcp_comment
    assert_redirected_to pcp_item_path( @pcp_item )

    patch pcp_subject_path( id: @pcp_subject, params:{ pcp_subject: { 
      pcp_steps_attributes: {  '0' => { id: @pcp_step.id, report_version: 'B', new_assmt: final_assessment }}}})
    @pcp_subject = assigns( :pcp_subject )
    @pcp_step = @pcp_subject.current_step
    assert_redirected_to pcp_subject_path( @pcp_subject )

    assert_no_difference( 'PcpStep.count' )do
      get pcp_subject_release_path( id: @pcp_subject )
    end
    @pcp_subject = assigns( :pcp_subject )
    @pcp_step = @pcp_subject.current_step
    assert_redirected_to pcp_release_doc_path( @pcp_subject, @pcp_step.step_no )

    # subject is closed and with presenting party, return to PcpItemsController

    switch_to_user @account_p

    assert @pcp_step.in_presenting_group?, @pcp_step.inspect
    assert @pcp_step.status_closed?

    # start testing

    # should get index

    get pcp_subject_pcp_items_path( pcp_subject_id: @pcp_subject )
    assert_response :success
    refute_nil assigns( :pcp_items )
    refute_nil assigns( :pcp_subject )
    refute_nil assigns( :pcp_group )

    # should get show

    get pcp_item_path( id: @pcp_item )
    assert_response :success
    refute_nil assigns( :pcp_subject )
    refute_nil assigns( :pcp_step )
    assert_nil @pcp_comments_show
    assert_nil @pcp_comment_edit
    assert_nil @pcp_item_show
    assert_nil @pcp_item_edit

    # should get next

    get pcp_item_next_path( id: @pcp_item )
    assert_response :success
    refute_nil assigns( :pcp_item )
    refute_nil assigns( :pcp_step )
    assert_nil @pcp_comments_show
    assert_nil @pcp_comment_edit
    assert_nil @pcp_item_show
    assert_nil @pcp_item_edit#

    # should not do an update_publish

    get pcp_item_publish_path( id: @pcp_item )
    assert_response :unprocessable_entity

    # should not get new

    get new_pcp_subject_pcp_item_path( pcp_subject_id: @pcp_subject )
    assert_response :unprocessable_entity

    # should not get new_comment

    get new_pcp_comment_path( id: @pcp_item )
    assert_response :unprocessable_entity

    # should not edit item

    get edit_pcp_item_path( id: @pcp_item )
    assert_response :unprocessable_entity

    # should not edit comment

    get edit_pcp_comment_path( id: @pcp_comment )
    assert_response :unprocessable_entity

    # should not create item

    post pcp_subject_pcp_items_path( pcp_subject_id: @pcp_subject )
    assert_response :unprocessable_entity

    # should not create comment

    post create_pcp_comment_path( id: @pcp_item )
    assert_response :unprocessable_entity

    # should not update item

    patch pcp_item_path( id: @pcp_item )
    assert_response :unprocessable_entity

    # should not update comment

    patch pcp_comment_path( id: @pcp_comment )
    assert_response :unprocessable_entity

    # should not destroy item

    assert_no_difference( 'PcpItem.count' )do
      delete pcp_item_path( id: @pcp_item )
    end
    refute_nil @pcp_subject = assigns( :pcp_subject )
    refute_nil @pcp_item = assigns( :pcp_item )
    assert @pcp_subject.user_is_owner_or_deputy?( @account_p, @pcp_item.pcp_step.acting_group_index )
    assert_redirected_to pcp_subject_pcp_items_path( @pcp_subject )

    # should not destroy comment

    assert_no_difference( 'PcpComment.count' )do
      delete pcp_comment_path( id: @pcp_comment )
    end
    assert_redirected_to pcp_item_path( @pcp_item )

  end

  end

end