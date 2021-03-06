ENV['RAILS_ENV'] ||= 'test'
#
# set $DEBUG = true here to turn on the debug flag for all tests
# set $DEBUG = true in a specific test is also possible
# 
# $DEBUG = true 
#
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # use this method to generate some "text [id]" string to test against

  def text_with_id( text, id )
    assert_not text.nil?
    assert_not id.nil?
    assert text.is_a? String
    assert id.is_a? Integer
    "#{ text } [#{ id }]"
  end

  # Add more helper methods to be used by all tests here...

  def validate_feature_class_attributes( id, access_level,
    control_level = ApplicationController::FEATURE_CONTROL_NONE, no_workflows = 0 )
    assert @controller.feature_identifier, 'feature_identifier not assigned'
    assert_equal id, @controller.feature_identifier, 'feature_identifier to not match'
    assert @controller.feature_access_level, 'feature_access_level not assigned'
    assert_equal access_level, @controller.feature_access_level, 'feature_access_level do not match'
    assert @controller.feature_control_level, 'feature_control_level not assigned'    
    assert_equal control_level, @controller.feature_control_level, 'feature_control_level do not match'
    assert @controller.no_workflows,  'no_workflows not assigned'
    assert_equal no_workflows, @controller.no_workflows, 'no_workflows do not match'
  end

  def check_for_cr
    assert_response :unauthorized
    assert_template 'my_change_requests/new'
  end

  def switch_to_user( user )
    get signoff_url       # @controller.delete_user
    signon_by_user( user ) # session[ :current_user_id ] = user
  end

  def signon_by_user( user )
    post signon_url, params: { acc_name: user.name, password: 'password' }
    follow_redirect!
  end

  def signoff_user
    get signoff_url
  end

end
