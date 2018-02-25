require 'test_helper'
class HomePageTest < ActionDispatch::IntegrationTest

  test 'see the sign on page' do
    get home_path
    assert_response :success
    assert_template :index
    assert_select 'title', 'TEST: Home Page'
  end

end
