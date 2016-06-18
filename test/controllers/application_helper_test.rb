# test methods in the ApplicationHelper file
# using accounts_controller as arbitrary controller

require 'test_helper'
class ApplicationHelperTest < ActionView::TestCase

  test 'breadcrumbs' do
    # problem: controller is 'test' and 'test' has no path ...:-(
    # puts breadcrumbs ???
  end

end
