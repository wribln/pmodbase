require 'test_helper'
class DsrDocGroupsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @account = accounts( :one )
    signon_by_user @account
    @dsr_doc_group = dsr_doc_groups( :dsr_group_one )
  end

  test 'check class attributes' do
    get dsr_doc_groups_path
    validate_feature_class_attributes FEATURE_ID_DSR_DOC_GROUPS, 
      ApplicationController::FEATURE_ACCESS_SOME, 
      ApplicationController::FEATURE_CONTROL_GRP
  end

  test 'should get index' do
    get dsr_doc_groups_path
    assert_response :success
    assert_not_nil assigns( :dsr_doc_groups )
  end

  test 'should get new' do
    get new_dsr_doc_group_path
    assert_response :success
  end

  test 'should create dsr_doc_group' do
    assert_difference( 'DsrDocGroup.count' ) do
      post dsr_doc_groups_path( params:{ dsr_doc_group: {
        code:     @dsr_doc_group.code,
        title:    @dsr_doc_group.title,
        group_id: @dsr_doc_group.group_id }})
      end
    assert_redirected_to dsr_doc_group_path( assigns( :dsr_doc_group ))
  end

  test 'should show dsr_doc_group' do
    get dsr_doc_group_path( id: @dsr_doc_group )
    assert_response :success
  end

  test 'should get edit' do
    get edit_dsr_doc_group_path( id: @dsr_doc_group )
    assert_response :success
  end

  test 'should update dsr_doc_group' do
    patch dsr_doc_group_path( id: @dsr_doc_group, params:{ dsr_doc_group: { code: @dsr_doc_group.code, title: @dsr_doc_group.title }})
    assert_redirected_to dsr_doc_group_path( assigns( :dsr_doc_group ))
  end

  test 'should destroy dsr_doc_group' do
    assert_difference('DsrDocGroup.count', -1) do
      delete dsr_doc_group_path( id: @dsr_doc_group )
    end
    assert_redirected_to dsr_doc_groups_path
  end

end
