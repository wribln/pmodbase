require 'test_helper'
class CfrRelationshipsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @cfr_relationship = cfr_relationships( :one_one )
    @account = accounts( :one )
    signon_by_user @account
  end

  test 'check class_attributes'  do
    get cfr_relationships_path
    validate_feature_class_attributes FEATURE_ID_CFR_RELATIONSHIPS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get cfr_relationships_path
    assert_response :success
    assert_not_nil assigns( :cfr_relationships )
  end

  test 'should get new' do
    get new_cfr_relationship_path
    assert_response :success
  end

  test 'should create cfr_relationship' do
    assert_difference( 'CfrRelationship.count', 2 ) do
      post cfr_relationships_path, params:{ cfr_relationship: { rs_group: @cfr_relationship.rs_group, labels: ['1','2'] }}
    end
    rl = assigns( :cfr_relationship_l )
    rr = assigns( :cfr_relationship_r )
    assert rl.valid?
    assert rr.valid?
    assert_redirected_to cfr_relationship_path( rl )
  end

  test 'force error on missing label 1' do
    assert_difference( 'CfrRelationship.count', 0 ) do
      post cfr_relationships_path, params:{ cfr_relationship: { rs_group: @cfr_relationship.rs_group, labels: ['','2'] }}
    end
    assert_response :success
    assert_includes assigns( :cfr_relationship_l ).errors, :label
  end

  test 'force error on missing label 2' do
    assert_difference( 'CfrRelationship.count', 0 ) do
      post cfr_relationships_path, params:{ cfr_relationship: { rs_group: @cfr_relationship.rs_group, labels: ['1',''] }}
    end
    assert_response :success
    assert_includes assigns( :cfr_relationship_l ).errors, :'reverse_rs.label'
  end

  test 'should show cfr_relationship' do
    get cfr_relationship_path( id: @cfr_relationship )
    assert_response :success
  end

  test 'should get edit' do
    get edit_cfr_relationship_path( id: @cfr_relationship )
    assert_response :success
  end

  test 'should update rs_group' do
    patch cfr_relationship_path( id: @cfr_relationship, params:{ cfr_relationship: { rs_group: @cfr_relationship.rs_group, labels: ['1','2'] }})
    rl = assigns( :cfr_relationship_l )
    rr = assigns( :cfr_relationship_r )
    assert rl.valid?
    assert rr.valid?
    assert_redirected_to cfr_relationship_path( rl )
  end

  test 'should destroy cfr_relationship' do
    assert_difference('CfrRelationship.count', -2 ) do
      delete cfr_relationship_path( id: @cfr_relationship )
    end
    assert_redirected_to cfr_relationships_path
  end
end
