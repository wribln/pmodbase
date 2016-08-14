require 'test_helper'
class ContactListsControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_CONTACT_LISTS, ApplicationController::FEATURE_ACCESS_USER
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :contact_list )
  end

  test "should get info" do
    get :info
    assert_response :success
    assert_not_nil assigns( :accounts )
  end

  test "should get person info" do 
    get :show, id: @account.person
    assert_response :success
  end

  test "CSV download" do
    get :index, format: :xls
    assert_equal <<END_OF_CSV, response.body
Group;Group Name;Person Name;Responsibility;E-Mail Address;Contact Type;Department;Address Details;Phone Office;Phone Mobile
ONE;Group 1;Person One;Maker;person.one@company.com;Project;"";"";"";""
ONE;Group 1;Person One;Maker;person.one@company.com;Home;"";"";"";""
ONE;Group 1;Person One;Doer;person.one@company.com;Project;"";"";"";""
ONE;Group 1;Person One;Doer;person.one@company.com;Home;"";"";"";""
END_OF_CSV
  end

end
