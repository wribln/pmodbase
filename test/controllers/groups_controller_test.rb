require 'test_helper'
class GroupsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @group = groups( :group_one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get groups_path
    validate_feature_class_attributes FEATURE_ID_GROUPS, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get groups_path
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test 'should get new' do
    get new_group_path
    assert_response :success
  end

  test 'should create group' do
    assert_difference( 'Group.count' )do
      post groups_path( params:{ group: { code: @group.code << 'a', label: @group.label, group_category_id: @group.group_category_id }})
    end
    assert_redirected_to group_path( assigns( :group ))
  end

  test 'should show group' do
    get group_path( id: @group )
    assert_response :success
  end

  test 'should get edit' do
    get edit_group_path( id: @group )
    assert_response :success
  end

  test 'should update group' do
    patch group_path( id: @group, params:{ group: { label: @group.label, code: @group.code }})
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should destroy group' do
    # this is only possible with a group not used by any one
    g = Group.new( code: 'ABC', label: 'abc', group_category_id: @group.group_category_id )
    assert g.save, g.errors.messages
    assert_difference('Group.count', -1) do
      delete group_path( id: g )
    end
    assert_redirected_to groups_path
  end
  
  test 'CSV download' do
    get groups_path( format: :xls )
    assert_equal <<END_OF_CSV, response.body
code;label;notes;seqno;group_category;sub_group_of;participating;s_sender_code;s_receiver_code;active;standard
TWO;Group 2;"";0;Group Category 1;Group 1;true;true;true;true;true
ONE;Group 1;"";0;Group Category 1;;true;true;true;true;true
END_OF_CSV
  end

end
