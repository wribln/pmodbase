require 'test_helper'

class HashtagsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @hashtag = hashtags( :one )
    signon_by_user accounts( :one )
  end

  test 'should get index' do
    get hashtags_path
    assert_response :success
    assert_not_nil assigns(:hashtags)
  end

  test 'should get new' do
    get new_hashtag_path
    assert_response :success
  end

  test 'should create hashtag' do
    assert_difference( 'Hashtag.count' ) do
      post hashtags_path( params:{ hashtag: { code: @hashtag.code + 'X', feature_id: @hashtag.feature_id, label: @hashtag.label }})
    end
    assert_redirected_to hashtag_path( assigns( :hashtag ))
  end

  test 'should show hashtag' do
    get hashtag_path( id: @hashtag )
    assert_response :success
  end

  test 'should get edit' do
    get edit_hashtag_path( id: @hashtag )
    assert_response :success
  end

  test 'should update hashtag' do
    patch hashtag_path( id: @hashtag, params:{ hashtag: { code: @hashtag.code, feature_id: @hashtag.feature_id, label: @hashtag.label }})
    assert_redirected_to hashtag_path( assigns( :hashtag ))
  end

  test 'should destroy hashtag' do
    assert_difference('Hashtag.count', -1) do
      delete hashtag_path( id: @hashtag )
    end
    assert_redirected_to hashtags_path
  end
end
