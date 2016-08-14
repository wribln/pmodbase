require 'test_helper'

class HelpPagesControllerTest < ActionController::TestCase

  setup do
    session[ :current_user_id ] = accounts( :one ).id
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_HELP_PAGES, 
      ApplicationController::FEATURE_ACCESS_ALL + 
      ApplicationController::FEATURE_ACCESS_NBP
  end

  test "Get Default Help (Home)" do
    get :show_default
    assert_response :success
    assert_template :home
  end

  test "Get Help Overview" do
    get :show, title: :home
    assert_response :success
    assert_template :home
  end

  # check help page availability - one per controller / feature

  begin
    # collect all files in directory
    help_files = Dir.entries( Rails.root.join( 'app', 'views', 'help_pages' ))
    # ignore template and any hidden files
    help_files.delete_if{ |fn| fn == 'template.html.erb' || fn[ 0 ] == '.' }
    # map file names to topics
    help_files.map!{ |fn| fn.split( '.').first }
    # loop over all help topics
    help_files.each do |topic|
      #topic = fn.split( '.' ).first
      test "Test Help on #{ topic.capitalize }" do
        assert_routing({ method: 'get', path: "/help/#{ topic }"}, { controller: 'help_pages', action: 'show', title: topic })
        get :show, title: topic
        assert_response :success
        assert_template topic
      end
    end

    test 'all help files in help index' do
      get :show, title: :help_pages
      assert_response :success
      help_files.each do |topic|
        assert_select "a[href=?]","/help/#{ topic }" #">>> missing help topic: #{ topic }"
      end
    end

  end

end
