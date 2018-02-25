require 'test_helper'
class ContactListsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @account = accounts( :one )
    signon_by_user @account
  end

  test 'check class_attributes'  do
    get contact_lists_path
    validate_feature_class_attributes FEATURE_ID_CONTACT_LISTS, ApplicationController::FEATURE_ACCESS_USER
  end

  test 'should get index' do
    get contact_lists_path
    assert_response :success
    assert_not_nil assigns( :contact_list )
  end

  test 'should get info' do
    get account_list_path
    assert_response :success
    assert_not_nil assigns( :accounts )
  end

  test 'should get person info' do 
    get contact_list_path( id: @account.person )
    assert_response :success
  end

  test 'CSV download' do
    get contact_lists_path( format: :xls )
    assert_equal <<END_OF_CSV, response.body
Group;Group Name;Person Name;Responsibility;E-Mail Address;Contact Type;Department;Address Details;Phone Office;Phone Mobile
ONE;Group 1;Person One;Maker;person.one@company.com;Project;"";"";"";""
ONE;Group 1;Person One;Maker;person.one@company.com;Home;"";"";"";""
ONE;Group 1;Person One;Doer;person.one@company.com;Project;"";"";"";""
ONE;Group 1;Person One;Doer;person.one@company.com;Home;"";"";"";""
END_OF_CSV
  end

end
