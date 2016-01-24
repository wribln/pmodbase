require 'test_helper'

class ContactInfosControllerTest < ActionController::TestCase

  setup do
    @contact_info = contact_infos(:one)
    @person = people( :person_two )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_CONTACT_INFOS, ApplicationController::FEATURE_ACCESS_SOME
  end

  test "ensure consistency of setup data" do
    assert_not_nil @contact_info.person_id
    assert_not_nil @person.id
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contact_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contact_info" do
    assert_difference('ContactInfo.count') do
      post :create, contact_info: { info_type: @contact_info.info_type, person_id: @person.id }
    end

    assert_redirected_to contact_info_path(assigns(:contact_info))
  end

  test "should show contact_info" do
    get :show, id: @contact_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contact_info
    assert_response :success
  end

  test "should update contact_info" do
    patch :update, id: @contact_info, contact_info: { person_id: @person.id }
    assert_redirected_to contact_info_path(assigns(:contact_info))
  end

  test "should destroy contact_info" do
    assert_difference('ContactInfo.count', -1) do
      delete :destroy, id: @contact_info
    end

    assert_redirected_to contact_infos_path
  end
end
