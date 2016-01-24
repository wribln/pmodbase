# implements of a >simple< breadcrumblist to be used in views:
# the information for the breadcrumblist is collected at 
# various times and places within the controller; output for
# a view is done finally in the breadcrumb_helper.rb
#
# Each breadcrumb here consist of the feature title with a path
# to the main page of that feature (normally the index page).
# The first breadcrumb is always the base page, the last crumb
# is the action of the current controller (which should be shown
# as the breadcrumb before the last one). For example:
#
#   <base page> / <feature controller> / index
#
# The module collects the breadcrumbs in a list of double tuples:
# the first item is either a controller's name as symbol or as
# as string, or it is nil for the last item which then would be
# the action name to be appended; the second item can be nil 
# (indicating that no path should be created for that breadcrumb),
# or a path for the controller.

module BreadcrumbList
  extend ActiveSupport::Concern 

  included do
    helper_method   :breadcrumbs_to_here
    before_action   :init_breadcrumbs
  end

  def breadcrumbs_to_here
    if session[ :keep_base_open ] then
      nil
    else
      @list_of_breadcrumbs
    end
  end

  protected

  # initialize the breadcrumbs list with the standard values - when possible
  # if the general controller path could not be generated, catch the error and 
  # leave the value at nil

  def init_breadcrumbs
    @list_of_breadcrumbs = [[ 'base', base_path ], [ controller_name, nil ], [ nil, action_name ]]
    set_breadcrumb_path( self.send( controller_name + '_path' ))
  rescue NoMethodError
  end

  public

  def parent_breadcrumb( bc_title, bc_path )
    @list_of_breadcrumbs.insert( -3, [ bc_title, bc_path ])
  end

  def set_final_breadcrumb( action )
    if action.nil? then
      @list_of_breadcrumbs.tap( &:pop ).last[ 1 ] = nil
    else
      @list_of_breadcrumbs.last[ 1 ] = action
    end
  end

  def set_breadcrumb_title( title )
    @list_of_breadcrumbs[ @list_of_breadcrumbs.last.first.nil? ? -2 : -1 ][ 0 ] = title
  end

  # define where to go back to

  def set_breadcrumb_path( path )
    @list_of_breadcrumbs[ @list_of_breadcrumbs.last.first.nil? ? -2 : -1 ][ 1 ] = path
  end

end


