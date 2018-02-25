require 'test_helper'
class ResponsibilitiesController1Test < ActionDispatch::IntegrationTest

  setup do
    @responsibility = responsibilities( :one )
    signon_by_user @a = accounts( :one )
    @request.env['HTTP_REFERER'] = 'http://test.host/index'
  end

  test 'check class_attributes'  do
    get responsibilities_path
    validate_feature_class_attributes FEATURE_ID_RESPONSIBILITIES, ApplicationController::FEATURE_ACCESS_SOME, ApplicationController::FEATURE_CONTROL_GRP, 0
  end

  test 'ensure correct setup' do
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_create ), 'no permission to create'
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_read ), 'no permission to read'
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_update ), 'no permission to update'
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_delete ), 'no permission to delete'
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_index ), 'no permission to index'
  end

  test 'should get index' do
    get responsibilities_path
    assert_response :success
    assert_not_nil assigns(:responsibilities)
  end

  test 'should get new' do
    get new_responsibility_path
    assert_response :success
  end

  test 'should create responsibility' do
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_create, @responsibility.group_id ), 'no permission!'
    assert_difference( 'Responsibility.count' ) do
      post responsibilities_path( params:{ responsibility: { group_id: @responsibility.group_id, 
        person_id: @responsibility.person_id,
        description: @responsibility.description, seqno: @responsibility.seqno }})
    end
    assert_redirected_to responsibility_path( assigns( :responsibility ))
  end

  test 'should show responsibility' do
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_read, @responsibility.group_id ), 'no permission!'
    get responsibility_path( id: @responsibility )
    assert_response :success
  end

  test 'should get edit' do
    get edit_responsibility_path( id: @responsibility )
    assert_response :success
  end

  test 'should update responsibility' do
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_update, @responsibility.group_id ), 'no permission!'
    patch responsibility_path( id: @responsibility, params:{ responsibility: { description: @responsibility.description, seqno: @responsibility.seqno }})
    assert_redirected_to responsibility_path(assigns(:responsibility))
  end

  test 'should destroy responsibility' do
    assert_equal 1, @a.permission_to_access( FEATURE_ID_RESPONSIBILITIES, :to_delete, @responsibility.group_id ), 'no permission!'
    assert_difference( 'Responsibility.count', -1 ) do
      delete responsibility_path( id: @responsibility )
    end
    assert_redirected_to responsibilities_path
  end

end
