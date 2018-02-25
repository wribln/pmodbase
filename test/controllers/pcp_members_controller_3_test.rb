require 'test_helper'
class PcpMembersController3Test < ActionDispatch::IntegrationTest

  # ensure that only the owner/deputy of the viewing group can make
  # respective changes

  # test suite 2 - commenting group

  setup do
    @pcp_member = pcp_members( :two )
    @pcp_subject = pcp_subjects( :two )
    @account = accounts( :three )
    signon_by_user @account
    pg1 = Permission4Group.new(
      account_id: @account.id,
      group_id: @pcp_subject.c_group_id,
      feature_id: FEATURE_ID_PCP_MEMBERS,
      to_index: 1, to_create: 1, to_read: 1, to_update: 1, to_delete: 1 )
    assert pg1.save
    pg2 = Permission4Group.new(
      account_id: @account.id,
      group_id: @pcp_subject.c_group_id,
      feature_id: FEATURE_ID_MY_PCP_SUBJECTS,
      to_index: 1, to_create: 1, to_read: 1, to_update: 1, to_delete: 1 )
    assert pg2.save
    @pcp_subject.c_owner_id = @account.id
    assert @pcp_subject.save, @pcp_subject.errors.inspect
  end

  test 'should get index' do
    get pcp_subject_pcp_members_path( pcp_subject_id: @pcp_subject )
    assert_response :success
    @pcp_members = assigns( :pcp_members )
    assert 1, @pcp_members.count
    assert_equal @pcp_members[0].id, pcp_members( :two ).id
  end

  test 'should get new' do
    get new_pcp_subject_pcp_member_path( pcp_subject_id: @pcp_subject )
    assert_response :success
  end

  test 'should create pcp_member' do
    assert_difference( 'PcpMember.count' ) do
      post pcp_subject_pcp_members_path( pcp_subject_id: @pcp_subject.id, params:{ pcp_member: {
        account_id: accounts( :one ),
        to_access: true }})
    end
    @pcp_member_new = assigns( :pcp_member )
    assert_redirected_to pcp_member_path( @pcp_member_new )
    assert_equal 1, @pcp_member_new.pcp_group
  end

  test 'should show pcp_item' do
    get pcp_member_path( id: @pcp_member )
    assert_response :success
  end

  test 'should get edit' do
    get edit_pcp_member_path( id: @pcp_member )
    assert_response :success
  end

  test 'should update pcp_member' do
    patch pcp_member_path( id: @pcp_member, params:{ pcp_member: {
      to_access: false,
      to_update: false }})
    assert_redirected_to pcp_member_path( assigns( :pcp_member ))
  end

  test 'should destroy pcp_member' do
    assert_difference('PcpMember.count', -1) do
      delete pcp_member_path( id: @pcp_member )
    end
    assert_redirected_to pcp_subject_pcp_members_path( @pcp_subject )
  end

end
