require 'test_helper'
class WebLinksControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    signon_by_user accounts( :one )
    @web_link = web_links(:one)
  end

  test 'check class_attributes' do
    get web_links_path
    validate_feature_class_attributes FEATURE_ID_WEB_LINKS, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get web_links_path
    assert_response :success
    assert_not_nil assigns( :web_links )
  end

  test 'should get new' do
    get new_web_link_path
    assert_response :success
  end

  test 'should create web_link' do
    assert_difference( 'WebLink.count' ) do
      post web_links_path, params:{ web_link:{ hyperlink: @web_link.hyperlink, label: @web_link.label, seqno: @web_link.seqno }}
    end
    assert_redirected_to web_link_path( assigns( :web_link ))
  end

  test 'should show web_link' do
    get web_link_path( id: @web_link )
    assert_response :success
  end

  test 'should get edit' do
    get edit_web_link_path( id: @web_link )
    assert_response :success
  end

  test 'should update web_link' do
    patch web_link_path( id: @web_link, params:{ web_link:{ hyperlink: @web_link.hyperlink, label: @web_link.label, seqno: @web_link.seqno }})
    assert_redirected_to web_link_path(assigns(:web_link))
  end

  test 'should destroy web_link' do
    assert_difference( 'WebLink.count', -1 ) do
      delete web_link_path( id: @web_link )
    end
    assert_redirected_to web_links_path
  end
end
