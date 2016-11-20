require 'test_helper'
class ContactListsTest < ActionDispatch::IntegrationTest

  test 'get index page with standard entries' do
    # fix password_digest
    assert Account.find( accounts( :one ).id).update(
      password: accounts( :one ).password_digest,
      password_confirmation: accounts( :one ).password_digest )

    open_session
    get home_path
    assert_response :success

    post_via_redirect signon_path, {
      acc_name: accounts( :one ).name,
      password: accounts( :one ).password_digest }
    assert_equal base_path, path

    get contact_lists_path
    assert_response :success
    assert_template 'index'
    assert_select 'title', 'TEST: Contact List'
  end

end
