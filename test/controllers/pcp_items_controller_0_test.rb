require 'test_helper'
class PcpItemsController0Test < ActionController::TestCase
  tests PcpItemsController

  setup do
    @pcp_item = pcp_items( :one )
    @pcp_subject = @pcp_item.pcp_subject
    @account = accounts( :account_one )
    session[ :current_user_id ] = @account.id
  end

  test 'should get index' do
    get :index, pcp_subject_id: @pcp_subject
    assert_response :success
    assert_not_nil assigns( :pcp_items )
  end

  test 'should get new' do
    get :new, pcp_subject_id: @pcp_subject
    assert_response :success
  end

  test 'should create pcp item' do
    assert_difference( 'PcpItem.count' ) do
      post :create, pcp_item: {
        author: 'poor me',
        description: @pcp_item.description,
        reference: @pcp_item.reference },
        pcp_subject_id: @pcp_item.pcp_subject_id
    end
    assert_redirected_to pcp_item_path( assigns( :pcp_item ))
  end

  test 'should create pcp comment' do
    assert_difference( 'PcpComment.count' )do
      post :create_comment, pcp_comment:{
        author: 'me, again',
        description: 'foobar' },
        id: @pcp_item.id
    end
    assert_redirected_to pcp_item_path( assigns( :pcp_item ))
  end

  test 'could not create pcp_item' do
    assert_difference( 'PcpItem.count', 0 ) do
      post :create, pcp_subject_id: @pcp_item.pcp_subject_id, pcp_item: { description: nil }
    end
    assert_template :new
    assert_response :success
  end

  test 'should show pcp_item' do
    get :show, id: @pcp_item
    assert_response :success
  end

  test 'should get next item' do
    assert pcp_items( :one ).id < pcp_items( :two ).id, "This test requires #{ pcp_items( :one ).id } < #{ pcp_items( :two ).id}"
    assert_equal 1, @pcp_item.seqno
    get :show_next, id: @pcp_item
    assert_response :success
    @pcp_item = assigns( :pcp_item )
    assert_equal 2, @pcp_item.seqno
    get :show_next, id: @pcp_item
    assert_response :success
    @pcp_item = assigns( :pcp_item )
    assert_equal 2, @pcp_item.seqno
  end

  test 'create new item and edit it' do
    pcp_item = @pcp_subject.pcp_items.new
    pcp_item.pcp_step = @pcp_subject.current_steps.first
    pcp_item.seqno = 0
    pcp_item.description = 'test'
    pcp_item.author = 'me'
    assert pcp_item.valid?, pcp_item.errors.inspect
    assert pcp_item.save
    get :edit, id: pcp_item
    assert_response :success  
  end

  test 'should get edit - redirect to edit comment' do
    get :edit, id: @pcp_item
    assert_redirected_to edit_pcp_comment_path( pcp_comments( :one ))
  end

  test 'should update pcp_item' do
    patch :update, id: @pcp_item, pcp_item: {
      author: 'poor me',
      description: @pcp_item.description,
      reference: @pcp_item.reference }
    assert_redirected_to pcp_item_path( assigns( :pcp_item ))
  end

  test 'should destroy pcp_item' do
    # create new item for next step
    @pcp_item = @pcp_subject.pcp_items.new
    @pcp_item.seqno = 0
    @pcp_item.pcp_step = pcp_steps( :two )
    @pcp_item.description = 'foobar'
    @pcp_item.author = 'me'
    assert @pcp_item.save, @pcp_item.errors.inspect
    refute @pcp_item.released?
    assert_difference('PcpItem.count', -1) do
      delete :destroy, id: @pcp_item
    end
    assert_redirected_to pcp_subject_pcp_items_path( @pcp_subject )
  end
end
