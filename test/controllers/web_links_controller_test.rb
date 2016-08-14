require 'test_helper'
class WebLinksControllerTest < ActionController::TestCase
  
  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
    @web_link = web_links(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :web_links )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create web_link" do
    assert_difference( 'WebLink.count' ) do
      post :create, web_link: {
        hyperlink: @web_link.hyperlink, 
        label: @web_link.label, 
        seqno: @web_link.seqno }
    end
    assert_redirected_to web_link_path(assigns(:web_link))
  end

  test "should show web_link" do
    get :show, id: @web_link
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @web_link
    assert_response :success
  end

  test "should update web_link" do
    patch :update, id: @web_link, web_link: { 
      hyperlink: @web_link.hyperlink,
      label: @web_link.label,
      seqno: @web_link.seqno }
    assert_redirected_to web_link_path(assigns(:web_link))
  end

  test "should destroy web_link" do
    assert_difference('WebLink.count', -1) do
      delete :destroy, id: @web_link
    end
    assert_redirected_to web_links_path
  end
end
