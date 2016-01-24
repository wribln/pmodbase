require 'test_helper'

class HomePageTest < ActionDispatch::IntegrationTest

  test 'see the sign on page' do
    get '/'
    assert_response :success
    assert_template 'index'
    assert_select 'title', 'pmodbase: Home Page'
  end

end
